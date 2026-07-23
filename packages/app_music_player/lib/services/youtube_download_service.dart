import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

/// youtube_explode_dart's HTTP calls have no built-in timeout — a stalled
/// connection (no response, not even a rejection) hangs forever rather than
/// throwing, which otherwise shows up in the UI as a download stuck at 0%
/// with no error. These caps make that fail loudly instead.
const _manifestTimeout = Duration(seconds: 20);
// This resets on every chunk received, so it's really a "max gap with zero
// data" cap, not a total-download-time cap — 30s is generous for a real
// connection but fails fast on a genuine stall.
const _downloadTimeout = Duration(seconds: 30);

class DownloadedStream {
  DownloadedStream({required this.filePath, required this.container});

  final String filePath;

  /// File extension of the downloaded stream, e.g. 'mp4', 'webm'.
  final String container;
}

/// Raw YouTube stream downloads (no transcoding/muxing — that's
/// [TranscodeService]'s job). Abstracted so widget tests and Linux dev
/// iteration never make a real network call.
abstract class YoutubeDownloadService {
  /// Downloads the best-available audio-only stream for [videoId] into
  /// [destinationDirectory], reporting 0.0-1.0 progress via [onProgress].
  Future<DownloadedStream> downloadBestAudio(
    String videoId,
    String destinationDirectory, {
    required void Function(double progress) onProgress,
  });

  /// Downloads the best-available video-only stream for [videoId] into
  /// [destinationDirectory], reporting 0.0-1.0 progress via [onProgress].
  Future<DownloadedStream> downloadBestVideo(
    String videoId,
    String destinationDirectory, {
    required void Function(double progress) onProgress,
  });
}

class PlatformYoutubeDownloadService implements YoutubeDownloadService {
  PlatformYoutubeDownloadService() : _client = yt.YoutubeExplode();

  final yt.YoutubeExplode _client;

  Future<DownloadedStream> _download(
    yt.StreamInfo streamInfo,
    String destinationDirectory,
    String baseName,
    void Function(double) onProgress,
  ) async {
    final container = streamInfo.container.name;
    final filePath = p.join(destinationDirectory, '$baseName.$container');
    // ignore: avoid_print
    print('[dl-trace] starting byte download to $filePath, size=${streamInfo.size}');
    final sink = File(filePath).openWrite();
    final totalBytes = streamInfo.size.totalBytes;
    var received = 0;
    var chunkCount = 0;
    try {
      await for (final chunk
          in _client.videos.streamsClient
              .get(streamInfo)
              .timeout(_downloadTimeout)) {
        received += chunk.length;
        chunkCount++;
        // ignore: avoid_print
        print('[dl-trace] chunk #$chunkCount, ${chunk.length} bytes, total received=$received/$totalBytes');
        sink.add(chunk);
        if (totalBytes > 0) {
          onProgress((received / totalBytes).clamp(0.0, 1.0));
        }
      }
      // ignore: avoid_print
      print('[dl-trace] stream loop finished, chunks=$chunkCount received=$received');
      await sink.flush();
    } finally {
      await sink.close();
    }
    return DownloadedStream(filePath: filePath, container: container);
  }

  @override
  Future<DownloadedStream> downloadBestAudio(
    String videoId,
    String destinationDirectory, {
    required void Function(double progress) onProgress,
  }) async {
    // ignore: avoid_print
    print('[dl-trace] getManifest starting for $videoId');
    final manifest = await _client.videos.streamsClient
        .getManifest(videoId)
        .timeout(_manifestTimeout);
    // ignore: avoid_print
    print('[dl-trace] getManifest returned, audioOnly=${manifest.audioOnly.length}');
    final streamInfo = manifest.audioOnly.withHighestBitrate();
    return _download(
      streamInfo,
      destinationDirectory,
      'audio_$videoId',
      onProgress,
    );
  }

  @override
  Future<DownloadedStream> downloadBestVideo(
    String videoId,
    String destinationDirectory, {
    required void Function(double progress) onProgress,
  }) async {
    final manifest = await _client.videos.streamsClient
        .getManifest(videoId)
        .timeout(_manifestTimeout);
    // Prefer mp4-container video-only streams: they mux cleanly (stream
    // copy, no re-encode) with the mp4/m4a audio-only stream. Falls back to
    // any container if no mp4 option is available at all.
    final mp4Streams = manifest.videoOnly
        .where((s) => s.container.name == 'mp4')
        .toList();
    final streamInfo = (mp4Streams.isNotEmpty
            ? mp4Streams
            : manifest.videoOnly.toList())
        .bestQuality;
    return _download(
      streamInfo,
      destinationDirectory,
      'video_$videoId',
      onProgress,
    );
  }
}

import 'dart:io';

import 'package:path/path.dart' as p;

import 'youtube_download_service.dart';

/// Stand-in for [YoutubeDownloadService] used on Linux and in tests. Writes a
/// small placeholder file rather than performing a real network download.
class FakeYoutubeDownloadService implements YoutubeDownloadService {
  Future<DownloadedStream> _fakeDownload(
    String destinationDirectory,
    String baseName,
    void Function(double) onProgress,
  ) async {
    for (final progress in [0.25, 0.5, 0.75, 1.0]) {
      onProgress(progress);
    }
    final filePath = p.join(destinationDirectory, '$baseName.bin');
    await File(filePath).writeAsBytes(const [0]);
    return DownloadedStream(filePath: filePath, container: 'bin');
  }

  @override
  Future<DownloadedStream> downloadBestAudio(
    String videoId,
    String destinationDirectory, {
    required void Function(double progress) onProgress,
  }) => _fakeDownload(destinationDirectory, 'audio_$videoId', onProgress);

  @override
  Future<DownloadedStream> downloadBestVideo(
    String videoId,
    String destinationDirectory, {
    required void Function(double progress) onProgress,
  }) => _fakeDownload(destinationDirectory, 'video_$videoId', onProgress);
}

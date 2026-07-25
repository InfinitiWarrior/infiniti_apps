import 'dart:async';
import 'dart:io';

import 'package:core/core.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;

import '../database/music_database.dart';
import '../services/download_format.dart';
import '../services/transcode_service.dart';
import '../services/youtube_download_service.dart';

/// Orchestrates the download pipeline: raw stream download (via
/// [YoutubeDownloadService]) followed by transcoding/muxing (via
/// [TranscodeService]), persisting progress/status to [MusicDatabase] at
/// each step so [DownloadsScreen] can reflect it live.
class DownloadRepository {
  DownloadRepository(this._database, this._downloadService, this._transcodeService);

  final MusicDatabase _database;
  final YoutubeDownloadService _downloadService;
  final TranscodeService _transcodeService;

  Stream<List<DownloadTask>> watchDownloadTasks() =>
      _database.watchDownloadTasks();

  Future<void> enqueueDownload({
    required String videoId,
    required String title,
    String? channelTitle,
    Duration? duration,
    required DownloadFormat format,
  }) async {
    final task = await _database.insertDownloadTask(
      DownloadTasksCompanion.insert(
        youtubeVideoId: videoId,
        title: title,
        channelTitle: Value(channelTitle),
        durationMs: Value(duration?.inMilliseconds),
        format: format.name,
        status: 'queued',
      ),
    );
    unawaited(_process(task));
  }

  Future<void> retry(int taskId) async {
    await _database.setDownloadTaskStatus(
      taskId,
      status: 'queued',
      progress: 0,
    );
    final task = await _database.getDownloadTask(taskId);
    unawaited(_process(task));
  }

  Future<void> remove(int taskId) => _database.removeDownloadTask(taskId);

  /// YouTube's CDN sometimes throttles a specific stream URL (manifest
  /// resolves fine, but the byte stream itself never yields data — surfaces
  /// as our own [YoutubeDownloadService] timeout). Since [attempt] re-fetches
  /// a fresh manifest each call, retrying gets a new signed URL rather than
  /// hammering the same stuck one. Gives up after [maxAttempts].
  Future<T> _withRetry<T>(
    int taskId,
    Future<T> Function() attempt, {
    int maxAttempts = 3,
  }) async {
    for (var attemptNumber = 1;; attemptNumber++) {
      try {
        return await attempt();
      } catch (e) {
        if (attemptNumber >= maxAttempts) rethrow;
        // ignore: avoid_print
        print(
          '[dl-trace] attempt $attemptNumber/$maxAttempts failed ($e), '
          'retrying with a fresh manifest',
        );
        await _database.setDownloadTaskProgress(taskId, 0);
        await Future.delayed(Duration(seconds: attemptNumber * 3));
      }
    }
  }

  Future<void> _process(DownloadTask task) async {
    final format = DownloadFormat.fromName(task.format);
    final tempDir = await _ensureDir(await _tempDirectory());
    // ignore: avoid_print
    print('[dl-trace] _process start, tempDir=$tempDir format=$format');
    try {
      await _database.setDownloadTaskStatus(task.id, status: 'downloading', progress: 0);
      if (format == DownloadFormat.mp3) {
        // ignore: avoid_print
        print('[dl-trace] calling downloadBestAudio for ${task.youtubeVideoId}');
        final audio = await _withRetry(
          task.id,
          () => _downloadService.downloadBestAudio(
            task.youtubeVideoId,
            tempDir,
            onProgress: (progress) =>
                _database.setDownloadTaskProgress(task.id, progress),
          ),
        );
        // ignore: avoid_print
        print('[dl-trace] downloadBestAudio returned: ${audio.filePath}');

        await _database.setDownloadTaskStatus(task.id, status: 'processing');
        final destinationDir = await _ensureDir(await _audioDirectory());
        final destinationPath = p.join(
          destinationDir,
          '${_sanitizedFileName(task)}.mp3',
        );
        await _transcodeService.transcodeToMp3(
          sourcePath: audio.filePath,
          destinationPath: destinationPath,
          title: task.title,
          artist: task.channelTitle,
        );

        final track = await _database.insertDownloadedTrack(
          TracksCompanion.insert(
            source: 'download',
            filePath: destinationPath,
            title: task.title,
            artist: Value(task.channelTitle),
            durationMs: task.durationMs ?? 0,
            youtubeVideoId: Value(task.youtubeVideoId),
          ),
        );
        await _database.completeDownloadTask(
          task.id,
          filePath: destinationPath,
          trackId: track.id,
        );
      } else {
        final video = await _withRetry(
          task.id,
          () => _downloadService.downloadBestVideo(
            task.youtubeVideoId,
            tempDir,
            onProgress: (progress) =>
                _database.setDownloadTaskProgress(task.id, progress * 0.5),
          ),
        );
        final audio = await _withRetry(
          task.id,
          () => _downloadService.downloadBestAudio(
            task.youtubeVideoId,
            tempDir,
            onProgress: (progress) => _database.setDownloadTaskProgress(
              task.id,
              0.5 + progress * 0.5,
            ),
          ),
        );

        await _database.setDownloadTaskStatus(task.id, status: 'processing');
        final destinationDir = await _ensureDir(await _videoDirectory());
        final destinationPath = p.join(
          destinationDir,
          '${_sanitizedFileName(task)}.mp4',
        );
        await _transcodeService.muxToMp4(
          videoPath: video.filePath,
          audioPath: audio.filePath,
          destinationPath: destinationPath,
        );

        await _database.completeDownloadTask(
          task.id,
          filePath: destinationPath,
        );
      }
    } catch (e, stackTrace) {
      // ignore: avoid_print
      print('[dl-trace] CAUGHT: $e\n$stackTrace');
      AppLogger.error(
        'Download failed for ${task.youtubeVideoId}',
        error: e,
        stackTrace: stackTrace,
      );
      await _database.failDownloadTask(task.id, e.toString());
    }
  }

  String _sanitizedFileName(DownloadTask task) {
    final safeTitle = task.title.replaceAll(RegExp(r'[/\\:*?"<>|]'), '_');
    return '${safeTitle}_${task.youtubeVideoId}';
  }

  Future<String> _tempDirectory() async {
    final documents = await AppPaths.documentsDirectory();
    return p.join(documents, 'downloads', '.tmp');
  }

  Future<String> _audioDirectory() async {
    final documents = await AppPaths.documentsDirectory();
    return p.join(documents, 'downloads', 'audio');
  }

  Future<String> _videoDirectory() async {
    final documents = await AppPaths.documentsDirectory();
    return p.join(documents, 'downloads', 'video');
  }

  Future<String> _ensureDir(String path) async {
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return path;
  }
}

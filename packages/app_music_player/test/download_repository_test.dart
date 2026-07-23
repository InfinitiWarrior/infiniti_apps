import 'dart:io';

import 'package:app_music_player/database/music_database.dart';
import 'package:app_music_player/repositories/download_repository.dart';
import 'package:app_music_player/services/download_format.dart';
import 'package:app_music_player/services/fake_transcode_service.dart';
import 'package:app_music_player/services/fake_youtube_download_service.dart';
import 'package:app_music_player/services/youtube_download_service.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

/// `AppPaths` (via `path_provider`) talks over a platform channel with no
/// handler under plain `test()` — the call just hangs forever. Point it at a
/// real temp directory instead, since DownloadRepository actually writes
/// files (even the fakes write placeholder bytes to disk).
class _FakePathProviderPlatform extends PathProviderPlatform {
  static final _tempDir = Directory.systemTemp.createTempSync(
    'app_music_player_test',
  );

  @override
  Future<String?> getApplicationSupportPath() async => _tempDir.path;

  @override
  Future<String?> getApplicationDocumentsPath() async => _tempDir.path;

  @override
  Future<String?> getTemporaryPath() async => _tempDir.path;
}

class _FailingYoutubeDownloadService implements YoutubeDownloadService {
  @override
  Future<DownloadedStream> downloadBestAudio(
    String videoId,
    String destinationDirectory, {
    required void Function(double progress) onProgress,
  }) => throw Exception('network unreachable');

  @override
  Future<DownloadedStream> downloadBestVideo(
    String videoId,
    String destinationDirectory, {
    required void Function(double progress) onProgress,
  }) => throw Exception('network unreachable');
}

Future<DownloadTask> _waitForSettled(DownloadRepository repository) {
  return repository
      .watchDownloadTasks()
      .firstWhere(
        (tasks) =>
            tasks.isNotEmpty &&
            (tasks.first.status == 'complete' ||
                tasks.first.status == 'failed'),
      )
      .then((tasks) => tasks.first);
}

void main() {
  PathProviderPlatform.instance = _FakePathProviderPlatform();

  late MusicDatabase database;

  setUp(() {
    database = MusicDatabase.forTesting(NativeDatabase.memory());
  });

  test('mp3 download completes and inserts a playable Track', () async {
    final repository = DownloadRepository(
      database,
      FakeYoutubeDownloadService(),
      FakeTranscodeService(),
    );

    await repository.enqueueDownload(
      videoId: 'abc123',
      title: 'Test Song',
      channelTitle: 'Test Channel',
      duration: const Duration(minutes: 3),
      format: DownloadFormat.mp3,
    );

    final task = await _waitForSettled(repository);
    expect(task.status, 'complete');
    expect(task.trackId, isNotNull);
    expect(task.filePath, endsWith('.mp3'));

    final tracks = await database.watchTracks().first;
    expect(tracks, hasLength(1));
    expect(tracks.single.title, 'Test Song');
    expect(tracks.single.source, 'download');
    expect(tracks.single.youtubeVideoId, 'abc123');

    await database.close();
  });

  test('mp4 download completes without creating a Track', () async {
    final repository = DownloadRepository(
      database,
      FakeYoutubeDownloadService(),
      FakeTranscodeService(),
    );

    await repository.enqueueDownload(
      videoId: 'xyz789',
      title: 'Test Video',
      format: DownloadFormat.mp4,
    );

    final task = await _waitForSettled(repository);
    expect(task.status, 'complete');
    expect(task.trackId, isNull);
    expect(task.filePath, endsWith('.mp4'));

    final tracks = await database.watchTracks().first;
    expect(tracks, isEmpty);

    await database.close();
  });

  test('failed download surfaces an error and does not insert a Track', () async {
    final repository = DownloadRepository(
      database,
      _FailingYoutubeDownloadService(),
      FakeTranscodeService(),
    );

    await repository.enqueueDownload(
      videoId: 'fail1',
      title: 'Will Fail',
      format: DownloadFormat.mp3,
    );

    final task = await _waitForSettled(repository);
    expect(task.status, 'failed');
    expect(task.errorMessage, contains('network unreachable'));
    expect(task.trackId, isNull);

    final tracks = await database.watchTracks().first;
    expect(tracks, isEmpty);

    await database.close();
  });

  test('retry re-runs a failed task', () async {
    final repository = DownloadRepository(
      database,
      FakeYoutubeDownloadService(),
      FakeTranscodeService(),
    );

    // Seed a failed task directly.
    final task = await database.insertDownloadTask(
      DownloadTasksCompanion.insert(
        youtubeVideoId: 'retry1',
        title: 'Retry Me',
        format: DownloadFormat.mp3.name,
        status: 'failed',
        errorMessage: const Value('boom'),
      ),
    );

    await repository.retry(task.id);

    final settled = await _waitForSettled(repository);
    expect(settled.status, 'complete');

    await database.close();
  });
}

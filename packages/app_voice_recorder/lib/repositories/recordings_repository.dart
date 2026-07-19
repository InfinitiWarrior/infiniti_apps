import 'dart:io';

import 'package:core/core.dart';
import 'package:path/path.dart' as p;

import '../database/recorder_database.dart';
import '../services/recording_format.dart';

/// Combines the recordings database with the on-disk audio files, so callers
/// never have to juggle file paths and DB rows separately.
class RecordingsRepository {
  RecordingsRepository(this._database);

  final RecorderDatabase _database;

  Future<String> _recordingsDirectory() async {
    final documents = await AppPaths.documentsDirectory();
    final dir = Directory(p.join(documents, 'recordings'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir.path;
  }

  Future<String> newRecordingPath(RecordingFormat format) async {
    final dir = await _recordingsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return p.join(dir, 'rec_$timestamp.${format.extension}');
  }

  Future<String> fullPathFor(Recording recording) async {
    final dir = await _recordingsDirectory();
    return p.join(dir, recording.fileName);
  }

  Stream<List<Recording>> watchRecordings() => _database.watchRecordings();

  Future<void> saveRecording({
    required String filePath,
    required Duration duration,
    required RecordingFormat format,
  }) {
    return _database.insertRecording(
      RecordingsCompanion.insert(
        fileName: p.basename(filePath),
        displayName: 'Recording ${DateTime.now().formattedTime}',
        format: format.name,
        durationMs: duration.inMilliseconds,
      ),
    );
  }

  Future<void> rename(int id, String newName) => _database.renameRecording(id, newName);

  Future<void> delete(Recording recording) async {
    final path = await fullPathFor(recording);
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
    await _database.deleteRecording(recording.id);
  }
}

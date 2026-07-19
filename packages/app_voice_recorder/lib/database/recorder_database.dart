import 'package:core/core.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;

part 'recorder_database.g.dart';

class Recordings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get fileName => text()();
  TextColumn get displayName => text()();
  TextColumn get format => text()();
  IntColumn get durationMs => integer()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Recordings])
class RecorderDatabase extends _$RecorderDatabase {
  RecorderDatabase() : super(openAppConnection('recorder.sqlite'));

  @visibleForTesting
  RecorderDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  Future<int> insertRecording(RecordingsCompanion entry) {
    return into(recordings).insert(entry);
  }

  Stream<List<Recording>> watchRecordings() {
    return (select(recordings)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  Future<void> renameRecording(int id, String newName) {
    return (update(recordings)..where((t) => t.id.equals(id))).write(
      RecordingsCompanion(displayName: Value(newName)),
    );
  }

  Future<Recording> getRecording(int id) {
    return (select(
      recordings,
    )..where((t) => t.id.equals(id))).getSingle();
  }

  Future<void> deleteRecording(int id) {
    return (delete(recordings)..where((t) => t.id.equals(id))).go();
  }
}

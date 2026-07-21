import 'package:core/core.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;

part 'nfc_database.g.dart';

/// What action produced a saved [ScanRecord].
enum ScanDirection { read, write, format }

class ScanRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get direction => textEnum<ScanDirection>()();
  TextColumn get idHex => text()();
  TextColumn get techList => text().withDefault(const Constant(''))();
  TextColumn get ndefSummary => text().nullable()();
  TextColumn get rawDumpHex => text().nullable()();
  TextColumn get label => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [ScanRecords])
class NfcDatabase extends _$NfcDatabase {
  NfcDatabase() : super(openAppConnection('nfc_toolkit.sqlite'));

  @visibleForTesting
  NfcDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  Future<int> addScanRecord(ScanRecordsCompanion entry) {
    return into(scanRecords).insert(entry);
  }

  Stream<List<ScanRecord>> watchHistory() {
    return (select(scanRecords)..orderBy([
          (t) => OrderingTerm.desc(t.createdAt),
          (t) => OrderingTerm.desc(t.id),
        ]))
        .watch();
  }

  Future<void> renameRecord(int id, String label) {
    return (update(scanRecords)..where((t) => t.id.equals(id))).write(
      ScanRecordsCompanion(label: Value(label)),
    );
  }

  Future<void> deleteRecord(int id) {
    return (delete(scanRecords)..where((t) => t.id.equals(id))).go();
  }
}

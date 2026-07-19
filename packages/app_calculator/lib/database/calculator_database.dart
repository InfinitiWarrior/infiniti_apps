import 'package:core/core.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;

part 'calculator_database.g.dart';

class HistoryEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get expression => text()();
  TextColumn get result => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [HistoryEntries])
class CalculatorDatabase extends _$CalculatorDatabase {
  CalculatorDatabase() : super(openAppConnection('calculator.sqlite'));

  @visibleForTesting
  CalculatorDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  Future<int> addHistoryEntry(String expression, String result) {
    return into(historyEntries).insert(
      HistoryEntriesCompanion.insert(expression: expression, result: result),
    );
  }

  Stream<List<HistoryEntry>> watchHistory({int limit = 100}) {
    return (select(historyEntries)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(limit))
        .watch();
  }

  Future<void> clearHistory() => delete(historyEntries).go();
}

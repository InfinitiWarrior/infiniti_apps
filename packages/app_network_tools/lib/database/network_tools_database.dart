import 'package:core/core.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;

part 'network_tools_database.g.dart';

enum NetworkToolType { ping, traceroute, portScan, dnsLookup, subnetCalc, whois }

class NetworkResults extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get toolType => textEnum<NetworkToolType>()();
  TextColumn get target => text()();
  TextColumn get summary => text()();
  TextColumn get details => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [NetworkResults])
class NetworkToolsDatabase extends _$NetworkToolsDatabase {
  NetworkToolsDatabase() : super(openAppConnection('network_tools.sqlite'));

  @visibleForTesting
  NetworkToolsDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  Future<int> addResult(NetworkResultsCompanion entry) {
    return into(networkResults).insert(entry);
  }

  Stream<List<NetworkResult>> watchHistory({NetworkToolType? toolType}) {
    final query = select(networkResults)
      ..orderBy([
        (t) => OrderingTerm.desc(t.createdAt),
        (t) => OrderingTerm.desc(t.id),
      ]);
    if (toolType != null) {
      query.where((t) => t.toolType.equalsValue(toolType));
    }
    return query.watch();
  }

  Future<void> deleteResult(int id) {
    return (delete(networkResults)..where((t) => t.id.equals(id))).go();
  }

  Future<void> clearHistory() => delete(networkResults).go();
}

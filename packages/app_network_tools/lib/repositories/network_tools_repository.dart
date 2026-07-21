import 'package:drift/drift.dart' show Value;

import '../database/network_tools_database.dart';

class NetworkToolsRepository {
  NetworkToolsRepository(this._database);

  final NetworkToolsDatabase _database;

  Stream<List<NetworkResult>> watchHistory({NetworkToolType? toolType}) {
    return _database.watchHistory(toolType: toolType);
  }

  Future<void> saveResult({
    required NetworkToolType toolType,
    required String target,
    required String summary,
    String? details,
  }) {
    return _database.addResult(
      NetworkResultsCompanion.insert(
        toolType: toolType,
        target: target,
        summary: summary,
        details: Value(details),
      ),
    );
  }

  Future<void> delete(int id) => _database.deleteResult(id);

  Future<void> clearHistory() => _database.clearHistory();
}

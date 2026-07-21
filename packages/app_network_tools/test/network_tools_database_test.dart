import 'package:app_network_tools/database/network_tools_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late NetworkToolsDatabase database;

  setUp(() {
    database = NetworkToolsDatabase.forTesting(NativeDatabase.memory());
  });

  test('addResult inserts and watchHistory returns newest first', () async {
    await database.addResult(
      NetworkResultsCompanion.insert(
        toolType: NetworkToolType.ping,
        target: '1.1.1.1',
        summary: 'ok',
      ),
    );
    await database.addResult(
      NetworkResultsCompanion.insert(
        toolType: NetworkToolType.dnsLookup,
        target: 'example.com',
        summary: 'ok',
      ),
    );

    final history = await database.watchHistory().first;
    expect(history, hasLength(2));
    expect(history.first.target, 'example.com');
    expect(history.first.toolType, NetworkToolType.dnsLookup);

    await database.close();
  });

  test('watchHistory filters by toolType', () async {
    await database.addResult(
      NetworkResultsCompanion.insert(
        toolType: NetworkToolType.ping,
        target: '1.1.1.1',
        summary: 'ok',
      ),
    );
    await database.addResult(
      NetworkResultsCompanion.insert(
        toolType: NetworkToolType.whois,
        target: 'example.com',
        summary: 'ok',
      ),
    );

    final pingOnly = await database.watchHistory(toolType: NetworkToolType.ping).first;
    expect(pingOnly, hasLength(1));
    expect(pingOnly.single.toolType, NetworkToolType.ping);

    await database.close();
  });

  test('deleteResult removes a single row', () async {
    final id = await database.addResult(
      NetworkResultsCompanion.insert(
        toolType: NetworkToolType.subnetCalc,
        target: '10.0.0.0/24',
        summary: 'ok',
      ),
    );

    await database.deleteResult(id);

    expect(await database.watchHistory().first, isEmpty);

    await database.close();
  });

  test('clearHistory removes everything', () async {
    await database.addResult(
      NetworkResultsCompanion.insert(
        toolType: NetworkToolType.ping,
        target: '1.1.1.1',
        summary: 'ok',
      ),
    );
    await database.addResult(
      NetworkResultsCompanion.insert(
        toolType: NetworkToolType.portScan,
        target: '1.1.1.1',
        summary: 'ok',
      ),
    );

    await database.clearHistory();

    expect(await database.watchHistory().first, isEmpty);

    await database.close();
  });
}

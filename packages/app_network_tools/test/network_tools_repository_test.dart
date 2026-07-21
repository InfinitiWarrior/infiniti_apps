import 'package:app_network_tools/database/network_tools_database.dart';
import 'package:app_network_tools/repositories/network_tools_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('saveResult stores optional details and delete removes it', () async {
    final database = NetworkToolsDatabase.forTesting(NativeDatabase.memory());
    final repository = NetworkToolsRepository(database);

    await repository.saveResult(
      toolType: NetworkToolType.whois,
      target: 'example.com',
      summary: 'Registered',
      details: 'full whois text',
    );

    final history = await repository.watchHistory().first;
    expect(history, hasLength(1));
    expect(history.single.details, 'full whois text');

    await repository.delete(history.single.id);
    expect(await repository.watchHistory().first, isEmpty);

    await database.close();
  });

  test('clearHistory delegates to the database', () async {
    final database = NetworkToolsDatabase.forTesting(NativeDatabase.memory());
    final repository = NetworkToolsRepository(database);

    await repository.saveResult(toolType: NetworkToolType.ping, target: '1.1.1.1', summary: 'ok');
    await repository.clearHistory();

    expect(await repository.watchHistory().first, isEmpty);

    await database.close();
  });
}

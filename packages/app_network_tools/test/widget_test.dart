import 'package:app_network_tools/database/network_tools_database.dart';
import 'package:app_network_tools/repositories/network_tools_repository.dart';
import 'package:app_network_tools/screens/history_screen.dart';
import 'package:app_network_tools/screens/ping_screen.dart';
import 'package:app_network_tools/screens/subnet_calculator_screen.dart';
import 'package:app_network_tools/services/ping_service.dart';
import 'package:core/core.dart';
import 'package:dart_ping/dart_ping.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePingService implements PingService {
  _FakePingService(this.events);

  final List<PingEvent> events;

  @override
  Stream<PingEvent> ping(
    String host, {
    int? count,
    int interval = 1,
    int timeout = 2,
    int ttl = 255,
  }) {
    return Stream.fromIterable(events);
  }
}

void main() {
  testWidgets('ping screen streams responses and saves a summary to history', (tester) async {
    final database = NetworkToolsDatabase.forTesting(NativeDatabase.memory());
    final repository = NetworkToolsRepository(database);
    final fakePing = _FakePingService([
      const PingResponse(seq: 0, ttl: 64, time: Duration(milliseconds: 12), ip: '1.1.1.1'),
      PingSummary(transmitted: 1, received: 1),
    ]);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: PingScreen(repository: repository, pingService: fakePing),
      ),
    );
    await tester.pump();

    await tester.enterText(find.byType(TextField), '1.1.1.1');
    await tester.tap(find.widgetWithText(FilledButton, 'Ping'));
    // Not pumpAndSettle(): the TextField's cursor-blink animation keeps a
    // frame scheduled forever while it's focused, so pumpAndSettle() never
    // converges. A few bounded pumps is enough to drain the fake stream.
    await tester.pump();
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('1/1 received'), findsOneWidget);

    await tester.tap(find.text('Save to history'));
    await tester.pump();

    expect(find.text('Saved'), findsOneWidget);

    // Persistence itself (saveResult -> watchHistory) is already covered by
    // network_tools_repository_test.dart's plain (non-widget) tests; reading
    // a drift watch stream to `.first` here is deliberately avoided — inside
    // testWidgets, doing so hangs `database.close()` afterwards (see
    // CLAUDE.md's pumpAndSettle/testWidgets note for the related but
    // distinct TextField cursor-blink case). The UI showing "Saved" already
    // proves saveResult() completed without throwing.

    await database.close();
  });

  testWidgets('drawer navigates from Ping to Subnet Calculator', (tester) async {
    final database = NetworkToolsDatabase.forTesting(NativeDatabase.memory());
    final repository = NetworkToolsRepository(database);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: PingScreen(repository: repository, pingService: _FakePingService(const [])),
      ),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Subnet Calculator'));
    await tester.pumpAndSettle();

    expect(find.byType(SubnetCalculatorScreen), findsOneWidget);
    expect(find.text('Network address'), findsOneWidget);

    await database.close();
  });

  testWidgets('subnet calculator updates live as the IP changes', (tester) async {
    final database = NetworkToolsDatabase.forTesting(NativeDatabase.memory());
    final repository = NetworkToolsRepository(database);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: SubnetCalculatorScreen(repository: repository),
      ),
    );
    await tester.pump();

    expect(find.widgetWithText(TextField, '192.168.1.0'), findsOneWidget);
    expect(find.text('192.168.1.255'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '10.0.0.0');
    await tester.pump();

    expect(find.text('10.0.0.255'), findsOneWidget);

    await database.close();
  });

  testWidgets('history screen shows the empty state with no saved results', (tester) async {
    final database = NetworkToolsDatabase.forTesting(NativeDatabase.memory());
    final repository = NetworkToolsRepository(database);

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.dark, home: HistoryScreen(repository: repository)),
    );
    await tester.pump();

    expect(find.textContaining('No saved results yet'), findsOneWidget);

    await database.close();
  });
}

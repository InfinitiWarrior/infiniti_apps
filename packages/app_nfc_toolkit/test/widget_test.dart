import 'package:app_nfc_toolkit/database/nfc_database.dart';
import 'package:app_nfc_toolkit/repositories/scan_repository.dart';
import 'package:app_nfc_toolkit/screens/home_screen.dart';
import 'package:app_nfc_toolkit/services/nfc_service.dart';
import 'package:core/core.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ndef_record/ndef_record.dart';
import 'package:nfc_manager/nfc_manager.dart';

class _FakeNfcService implements NfcService {
  NfcAvailability availability = NfcAvailability.enabled;
  TagInfo discoveredInfo = const TagInfo(
    idHex: 'AA BB CC DD',
    techList: ['android.nfc.tech.Ndef', 'android.nfc.tech.NfcA'],
    ndefMessage: null,
    ndefWritable: true,
    ndefMaxSize: 137,
    canDump: false,
  );
  NdefMessage? lastWrittenMessage;

  @override
  Future<NfcAvailability> checkAvailability() async => availability;

  @override
  Future<void> startSession({
    required void Function(NfcTag tag) onDiscovered,
    void Function(String message)? onError,
  }) async {
    if (availability != NfcAvailability.enabled) {
      onError?.call('unavailable');
      return;
    }
    onDiscovered(const NfcTag(data: Object()));
  }

  @override
  Future<void> stopSession({String? errorMessage}) async {}

  @override
  TagInfo readTagInfo(NfcTag tag) => discoveredInfo;

  @override
  Future<void> writeNdefMessage(NfcTag tag, NdefMessage message) async {
    lastWrittenMessage = message;
  }

  @override
  Future<void> formatTag(NfcTag tag) async {}

  @override
  Future<List<int>?> dumpPages(NfcTag tag) async => null;

  @override
  void dispose() {}
}

void main() {
  testWidgets('scan tab reads a tag and shows its info', (tester) async {
    final database = NfcDatabase.forTesting(NativeDatabase.memory());
    final repository = ScanRepository(database);
    final nfcService = _FakeNfcService();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: HomeScreen(nfcService: nfcService, repository: repository),
      ),
    );
    await tester.pump();

    expect(find.text('Start scan'), findsOneWidget);

    await tester.tap(find.text('Start scan'));
    await tester.pumpAndSettle();

    expect(find.text('Tag detected'), findsOneWidget);
    expect(find.textContaining('AA BB CC DD'), findsOneWidget);

    await database.close();
  });

  testWidgets('write tab composes and writes a text record', (tester) async {
    final database = NfcDatabase.forTesting(NativeDatabase.memory());
    final repository = ScanRepository(database);
    final nfcService = _FakeNfcService();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: HomeScreen(nfcService: nfcService, repository: repository),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Write'));
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'Hello tag');
    await tester.tap(find.text('Write to tag'));
    await tester.pumpAndSettle();

    expect(find.text('Written successfully'), findsOneWidget);
    expect(nfcService.lastWrittenMessage, isNotNull);

    await database.close();
  });

  testWidgets('history tab shows the empty state with no saved scans', (tester) async {
    final database = NfcDatabase.forTesting(NativeDatabase.memory());
    final repository = ScanRepository(database);
    final nfcService = _FakeNfcService();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: HomeScreen(nfcService: nfcService, repository: repository),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('History'));
    await tester.pump();

    expect(find.textContaining('No saved scans yet'), findsOneWidget);

    await database.close();
  });
}

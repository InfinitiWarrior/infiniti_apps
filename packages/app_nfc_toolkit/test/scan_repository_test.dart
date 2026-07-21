import 'package:app_nfc_toolkit/database/nfc_database.dart';
import 'package:app_nfc_toolkit/repositories/scan_repository.dart';
import 'package:app_nfc_toolkit/services/ndef_codec.dart';
import 'package:app_nfc_toolkit/services/nfc_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ndef_record/ndef_record.dart';

void main() {
  test('saveScan summarizes the tag\'s NDEF message', () async {
    final database = NfcDatabase.forTesting(NativeDatabase.memory());
    final repository = ScanRepository(database);

    final info = TagInfo(
      idHex: 'AA BB CC DD',
      techList: const ['android.nfc.tech.Ndef', 'android.nfc.tech.NfcA'],
      ndefMessage: NdefMessage(records: [encodeTextRecord('hello')]),
      ndefWritable: true,
      ndefMaxSize: 137,
      canDump: false,
    );

    await repository.saveScan(direction: ScanDirection.read, info: info);

    final history = await repository.watchHistory().first;
    expect(history, hasLength(1));
    expect(history.single.idHex, 'AA BB CC DD');
    expect(history.single.techList, 'android.nfc.tech.Ndef, android.nfc.tech.NfcA');
    expect(history.single.ndefSummary, 'hello');

    await database.close();
  });

  test('saveScan uses the override message instead of the stale tag info for writes', () async {
    final database = NfcDatabase.forTesting(NativeDatabase.memory());
    final repository = ScanRepository(database);

    final staleInfo = TagInfo(
      idHex: 'AA BB',
      techList: const [],
      ndefMessage: NdefMessage(records: [encodeTextRecord('old content')]),
      ndefWritable: true,
      ndefMaxSize: 48,
      canDump: false,
    );
    final justWritten = NdefMessage(records: [encodeUriRecord('https://example.com')]);

    await repository.saveScan(direction: ScanDirection.write, info: staleInfo, message: justWritten);

    final history = await repository.watchHistory().first;
    expect(history.single.ndefSummary, 'https://example.com');

    await database.close();
  });

  test('saveScan stores a hex dump when provided', () async {
    final database = NfcDatabase.forTesting(NativeDatabase.memory());
    final repository = ScanRepository(database);

    final info = TagInfo(
      idHex: 'AA BB',
      techList: const [],
      ndefMessage: null,
      ndefWritable: false,
      ndefMaxSize: null,
      canDump: true,
    );

    await repository.saveScan(direction: ScanDirection.read, info: info, dumpBytes: [0xDE, 0xAD]);

    final history = await repository.watchHistory().first;
    expect(history.single.rawDumpHex, 'DE AD');

    await database.close();
  });

  test('rename and delete pass through to the database', () async {
    final database = NfcDatabase.forTesting(NativeDatabase.memory());
    final repository = ScanRepository(database);

    final info = TagInfo(
      idHex: 'AA BB',
      techList: const [],
      ndefMessage: null,
      ndefWritable: false,
      ndefMaxSize: null,
      canDump: false,
    );
    await repository.saveScan(direction: ScanDirection.read, info: info);
    final id = (await repository.watchHistory().first).single.id;

    await repository.rename(id, 'Front door');
    expect((await repository.watchHistory().first).single.label, 'Front door');

    await repository.delete(id);
    expect(await repository.watchHistory().first, isEmpty);

    await database.close();
  });
}

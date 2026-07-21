import 'package:app_nfc_toolkit/database/nfc_database.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late NfcDatabase database;

  setUp(() {
    database = NfcDatabase.forTesting(NativeDatabase.memory());
  });

  test('addScanRecord inserts and watchHistory reflects it, newest first', () async {
    await database.addScanRecord(
      ScanRecordsCompanion.insert(direction: ScanDirection.read, idHex: 'AA BB'),
    );
    await database.addScanRecord(
      ScanRecordsCompanion.insert(direction: ScanDirection.write, idHex: 'CC DD'),
    );

    final history = await database.watchHistory().first;
    expect(history, hasLength(2));
    expect(history.first.idHex, 'CC DD');
    expect(history.first.direction, ScanDirection.write);

    await database.close();
  });

  test('renameRecord updates the label', () async {
    final id = await database.addScanRecord(
      ScanRecordsCompanion.insert(direction: ScanDirection.read, idHex: 'AA BB'),
    );

    await database.renameRecord(id, 'My office badge');

    final history = await database.watchHistory().first;
    expect(history.single.label, 'My office badge');

    await database.close();
  });

  test('deleteRecord removes it', () async {
    final id = await database.addScanRecord(
      ScanRecordsCompanion.insert(direction: ScanDirection.format, idHex: 'AA BB'),
    );

    await database.deleteRecord(id);

    final history = await database.watchHistory().first;
    expect(history, isEmpty);

    await database.close();
  });

  test('stores optional fields', () async {
    await database.addScanRecord(
      ScanRecordsCompanion.insert(
        direction: ScanDirection.read,
        idHex: 'AA BB',
        techList: const Value('Ndef, NfcA'),
        ndefSummary: const Value('Hello'),
        rawDumpHex: const Value('00 01 02'),
      ),
    );

    final record = await database.watchHistory().first.then((r) => r.single);
    expect(record.techList, 'Ndef, NfcA');
    expect(record.ndefSummary, 'Hello');
    expect(record.rawDumpHex, '00 01 02');

    await database.close();
  });
}

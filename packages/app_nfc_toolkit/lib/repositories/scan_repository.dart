import 'package:drift/drift.dart' show Value;
import 'package:ndef_record/ndef_record.dart';

import '../database/nfc_database.dart';
import '../services/ndef_codec.dart';
import '../services/nfc_service.dart';
import '../utils/hex_format.dart';

class ScanRepository {
  ScanRepository(this._database);

  final NfcDatabase _database;

  Stream<List<ScanRecord>> watchHistory() => _database.watchHistory();

  /// Saves a scan/write/format action to history.
  ///
  /// [message] overrides [TagInfo.ndefMessage] for the summary — used after
  /// a write, since the tag's cached message from the scan that discovered
  /// it is now stale.
  Future<void> saveScan({
    required ScanDirection direction,
    required TagInfo info,
    NdefMessage? message,
    List<int>? dumpBytes,
    String? label,
  }) {
    return _database.addScanRecord(
      ScanRecordsCompanion.insert(
        direction: direction,
        idHex: info.idHex,
        techList: Value(info.techList.join(', ')),
        ndefSummary: Value(_summarize(message ?? info.ndefMessage)),
        rawDumpHex: Value(dumpBytes == null ? null : bytesToHex(dumpBytes)),
        label: Value(label),
      ),
    );
  }

  Future<void> rename(int id, String label) => _database.renameRecord(id, label);

  Future<void> delete(int id) => _database.deleteRecord(id);

  String? _summarize(NdefMessage? message) {
    if (message == null || message.records.isEmpty) return null;
    return message.records.map((r) => describeRecord(r).detail).join(' · ');
  }
}

import 'package:ndef_record/ndef_record.dart';
import 'package:nfc_manager/nfc_manager.dart' show NfcAvailability, NfcTag;

/// Snapshot of a discovered tag's info, independent of the underlying
/// plugin's platform-specific tech classes.
class TagInfo {
  const TagInfo({
    required this.idHex,
    required this.techList,
    required this.ndefMessage,
    required this.ndefWritable,
    required this.ndefMaxSize,
    required this.canDump,
  });

  final String idHex;
  final List<String> techList;
  final NdefMessage? ndefMessage;
  final bool ndefWritable;
  final int? ndefMaxSize;

  /// Whether [NfcService.dumpPages] is likely to work for this tag
  /// (MIFARE Ultralight/NTAG family only — see CLAUDE.md scope note).
  final bool canDump;
}

/// Abstract so widget tests never touch the real `nfc_manager` platform
/// channel — it hangs indefinitely under `flutter_test` with no mocks, the
/// same reason `record`/`just_audio` are injected in the other apps.
abstract class NfcService {
  Future<NfcAvailability> checkAvailability();

  /// Starts a scan session. [onDiscovered] fires once per tag; the session
  /// stays open (per Android's default polling behavior) until
  /// [stopSession] is called, so callers can scan repeatedly.
  Future<void> startSession({
    required void Function(NfcTag tag) onDiscovered,
    void Function(String message)? onError,
  });

  Future<void> stopSession({String? errorMessage});

  /// Reads the general info (UID, tech list, cached NDEF message) off an
  /// already-discovered tag. Does not itself require another scan.
  TagInfo readTagInfo(NfcTag tag);

  Future<void> writeNdefMessage(NfcTag tag, NdefMessage message);

  /// Erases the tag's NDEF content (writes an empty message), formatting it
  /// for NDEF use first if it isn't already.
  Future<void> formatTag(NfcTag tag);

  /// Best-effort raw memory dump. Only implemented for tag families that
  /// expose plain page reads (MIFARE Ultralight/NTAG) — returns null
  /// otherwise. MIFARE Classic is deliberately unsupported: dumping it
  /// requires per-sector key authentication, which is out of scope for a
  /// personal toolkit.
  Future<List<int>?> dumpPages(NfcTag tag);

  void dispose();
}

import 'dart:io';
import 'dart:typed_data';

import 'package:ndef_record/ndef_record.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/nfc_manager_android.dart';

import '../utils/hex_format.dart';
import 'nfc_service.dart';

/// Real implementation wrapping `nfc_manager`.
///
/// Android-only by design: `nfc_manager`'s tag-technology API (NDEF, NFC-A,
/// MIFARE Ultralight, …) is split into separate per-platform classes, and
/// the developer's only test device is Android. iOS is treated the same as
/// an unsupported desktop platform rather than maintained as an unverified,
/// untested code path.
class PlatformNfcService implements NfcService {
  @override
  Future<NfcAvailability> checkAvailability() async {
    if (!Platform.isAndroid) return NfcAvailability.unsupported;
    return NfcManager.instance.checkAvailability();
  }

  @override
  Future<void> startSession({
    required void Function(NfcTag tag) onDiscovered,
    void Function(String message)? onError,
  }) async {
    if (!Platform.isAndroid) {
      onError?.call('NFC is only supported on Android in this app.');
      return;
    }
    await NfcManager.instance.startSession(
      pollingOptions: {
        NfcPollingOption.iso14443,
        NfcPollingOption.iso15693,
        NfcPollingOption.iso18092,
      },
      onDiscovered: onDiscovered,
    );
  }

  @override
  Future<void> stopSession({String? errorMessage}) async {
    if (!Platform.isAndroid) return;
    await NfcManager.instance.stopSession(errorMessageIos: errorMessage);
  }

  @override
  TagInfo readTagInfo(NfcTag tag) {
    final androidTag = NfcTagAndroid.from(tag);
    final ndef = NdefAndroid.from(tag);
    final ultralight = MifareUltralightAndroid.from(tag);
    return TagInfo(
      idHex: bytesToHex(androidTag?.id ?? Uint8List(0)),
      techList: androidTag?.techList ?? const [],
      ndefMessage: ndef?.cachedNdefMessage,
      ndefWritable: ndef?.isWritable ?? false,
      ndefMaxSize: ndef?.maxSize,
      canDump: ultralight != null,
    );
  }

  @override
  Future<void> writeNdefMessage(NfcTag tag, NdefMessage message) async {
    final ndef = NdefAndroid.from(tag);
    if (ndef == null) {
      throw StateError('This tag does not support NDEF.');
    }
    if (!ndef.isWritable) {
      throw StateError('This tag is read-only.');
    }
    await ndef.writeNdefMessage(message);
  }

  @override
  Future<void> formatTag(NfcTag tag) async {
    final ndef = NdefAndroid.from(tag);
    if (ndef != null) {
      if (!ndef.isWritable) {
        throw StateError('This tag is read-only.');
      }
      await ndef.writeNdefMessage(const NdefMessage(records: []));
      return;
    }
    final formatable = NdefFormatableAndroid.from(tag);
    if (formatable != null) {
      await formatable.format(const NdefMessage(records: []));
      return;
    }
    throw StateError('This tag does not support NDEF formatting.');
  }

  @override
  Future<List<int>?> dumpPages(NfcTag tag) async {
    final ultralight = MifareUltralightAndroid.from(tag);
    if (ultralight == null) return null;

    final bytes = <int>[];
    // Ultralight/NTAG pages are 4 bytes each; readPages returns 4 pages
    // (16 bytes) per call. Stop at the first out-of-range read — that's how
    // the plugin signals end-of-memory, since tag capacity varies by model
    // (plain Ultralight: 16 pages, NTAG215: 135, NTAG216: 231, ...).
    for (var page = 0; page < 256; page += 4) {
      try {
        final chunk = await ultralight.readPages(pageOffset: page);
        bytes.addAll(chunk);
      } catch (_) {
        break;
      }
    }
    return bytes;
  }

  @override
  void dispose() {}
}

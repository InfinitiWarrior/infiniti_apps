import 'dart:convert';
import 'dart:typed_data';

import 'package:ndef_record/ndef_record.dart';

import '../utils/hex_format.dart';

/// Encodes and decodes the two NDEF record types this app supports writing:
/// RTD Text and RTD URI. Pure Dart / no platform dependency, per the NFC
/// Forum "Text Record Type Definition" and "URI Record Type Definition"
/// specs, so it's fully unit-testable without a real tag or plugin.

const _uriAbbreviations = <int, String>{
  0x00: '',
  0x01: 'http://www.',
  0x02: 'https://www.',
  0x03: 'http://',
  0x04: 'https://',
  0x05: 'tel:',
  0x06: 'mailto:',
  0x07: 'ftp://anonymous:anonymous@',
  0x08: 'ftp://ftp.',
  0x09: 'ftps://',
  0x0A: 'sftp://',
  0x0B: 'smb://',
  0x0C: 'nfs://',
  0x0D: 'ftp://',
  0x0E: 'dav://',
  0x0F: 'news:',
  0x10: 'telnet://',
  0x11: 'imap:',
  0x12: 'rtsp://',
  0x13: 'urn:',
  0x14: 'pop:',
  0x15: 'sip:',
  0x16: 'sips:',
  0x17: 'tftp:',
  0x18: 'btspp://',
  0x19: 'btl2cap://',
  0x1A: 'btgoep://',
  0x1B: 'tcpobex://',
  0x1C: 'irdaobex://',
  0x1D: 'file://',
  0x1E: 'urn:epc:id:',
  0x1F: 'urn:epc:tag:',
  0x20: 'urn:epc:pat:',
  0x21: 'urn:epc:raw:',
  0x22: 'urn:epc:',
  0x23: 'urn:nfc:',
};

// Longest-prefix-first so encoding picks the most specific abbreviation
// (e.g. "https://www." over "https://").
final _uriAbbreviationsByLength = _uriAbbreviations.entries
    .where((e) => e.key != 0x00)
    .toList()
  ..sort((a, b) => b.value.length.compareTo(a.value.length));

NdefRecord encodeTextRecord(String text, {String languageCode = 'en'}) {
  final languageBytes = ascii.encode(languageCode);
  if (languageBytes.length > 63) {
    throw ArgumentError('languageCode must be at most 63 bytes.');
  }
  final textBytes = utf8.encode(text);
  final payload = Uint8List(1 + languageBytes.length + textBytes.length)
    ..[0] = languageBytes.length // status byte: UTF-8, language code length
    ..setRange(1, 1 + languageBytes.length, languageBytes)
    ..setRange(1 + languageBytes.length, 1 + languageBytes.length + textBytes.length, textBytes);

  return NdefRecord(
    typeNameFormat: TypeNameFormat.wellKnown,
    type: Uint8List.fromList(ascii.encode('T')),
    identifier: Uint8List(0),
    payload: payload,
  );
}

class DecodedText {
  const DecodedText({required this.text, required this.languageCode});
  final String text;
  final String languageCode;
}

/// Returns null if [record] is not a well-formed RTD Text record.
DecodedText? decodeTextRecord(NdefRecord record) {
  if (record.typeNameFormat != TypeNameFormat.wellKnown ||
      ascii.decode(record.type, allowInvalid: true) != 'T') {
    return null;
  }
  final payload = record.payload;
  if (payload.isEmpty) return null;

  final statusByte = payload[0];
  final isUtf16 = (statusByte & 0x80) != 0;
  final languageLength = statusByte & 0x3F;
  if (payload.length < 1 + languageLength) return null;

  final languageCode = ascii.decode(payload.sublist(1, 1 + languageLength), allowInvalid: true);
  final textBytes = payload.sublist(1 + languageLength);
  final text = isUtf16 ? String.fromCharCodes(textBytes) : utf8.decode(textBytes, allowMalformed: true);
  return DecodedText(text: text, languageCode: languageCode);
}

NdefRecord encodeUriRecord(String uri) {
  var code = 0x00;
  var remainder = uri;
  for (final entry in _uriAbbreviationsByLength) {
    if (uri.startsWith(entry.value)) {
      code = entry.key;
      remainder = uri.substring(entry.value.length);
      break;
    }
  }
  final uriBytes = utf8.encode(remainder);
  final payload = Uint8List(1 + uriBytes.length)
    ..[0] = code
    ..setRange(1, 1 + uriBytes.length, uriBytes);

  return NdefRecord(
    typeNameFormat: TypeNameFormat.wellKnown,
    type: Uint8List.fromList(ascii.encode('U')),
    identifier: Uint8List(0),
    payload: payload,
  );
}

/// Returns null if [record] is not a well-formed RTD URI record.
String? decodeUriRecord(NdefRecord record) {
  if (record.typeNameFormat != TypeNameFormat.wellKnown ||
      ascii.decode(record.type, allowInvalid: true) != 'U') {
    return null;
  }
  final payload = record.payload;
  if (payload.isEmpty) return null;

  final prefix = _uriAbbreviations[payload[0]] ?? '';
  final rest = utf8.decode(payload.sublist(1), allowMalformed: true);
  return '$prefix$rest';
}

enum RecordKind { text, uri, other }

/// Human-readable view of any NDEF record, for display in the UI — decodes
/// Text and URI records, and falls back to a hex payload preview otherwise.
class DisplayRecord {
  const DisplayRecord({required this.kind, required this.title, required this.detail});

  final RecordKind kind;
  final String title;
  final String detail;
}

DisplayRecord describeRecord(NdefRecord record) {
  final text = decodeTextRecord(record);
  if (text != null) {
    return DisplayRecord(kind: RecordKind.text, title: 'Text', detail: text.text);
  }
  final uri = decodeUriRecord(record);
  if (uri != null) {
    return DisplayRecord(kind: RecordKind.uri, title: 'URI', detail: uri);
  }
  final typeStr = ascii.decode(record.type, allowInvalid: true).trim();
  return DisplayRecord(
    kind: RecordKind.other,
    title: typeStr.isEmpty ? 'Unknown (${record.typeNameFormat.name})' : typeStr,
    detail: record.payload.isEmpty ? '(empty payload)' : bytesToHex(record.payload),
  );
}

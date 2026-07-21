import 'dart:convert';
import 'dart:typed_data';

import 'package:app_nfc_toolkit/services/ndef_codec.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ndef_record/ndef_record.dart';

void main() {
  group('text records', () {
    test('round-trips plain text with the default language code', () {
      final record = encodeTextRecord('Hello, tag!');
      final decoded = decodeTextRecord(record);

      expect(decoded, isNotNull);
      expect(decoded!.text, 'Hello, tag!');
      expect(decoded.languageCode, 'en');
    });

    test('round-trips a custom language code', () {
      final record = encodeTextRecord('Bonjour', languageCode: 'fr');
      final decoded = decodeTextRecord(record);

      expect(decoded!.languageCode, 'fr');
      expect(decoded.text, 'Bonjour');
    });

    test('round-trips non-ASCII UTF-8 text', () {
      final record = encodeTextRecord('日本語のテスト');
      final decoded = decodeTextRecord(record);

      expect(decoded!.text, '日本語のテスト');
    });

    test('decodeTextRecord returns null for a non-text record', () {
      final record = encodeUriRecord('https://example.com');
      expect(decodeTextRecord(record), isNull);
    });
  });

  group('uri records', () {
    test('round-trips a plain URI with no abbreviation', () {
      final record = encodeUriRecord('ftp://custom.example/path');
      expect(decodeUriRecord(record), 'ftp://custom.example/path');
    });

    test('uses the https://www. abbreviation when applicable', () {
      final record = encodeUriRecord('https://www.example.com/page');
      // Abbreviated payload should be shorter than the full URI.
      expect(record.payload.length, lessThan('https://www.example.com/page'.length));
      expect(decodeUriRecord(record), 'https://www.example.com/page');
    });

    test('prefers the longest matching abbreviation', () {
      final record = encodeUriRecord('https://www.example.com');
      expect(record.payload[0], 0x02); // "https://www." not just "https://"
    });

    test('round-trips tel: and mailto: URIs', () {
      expect(decodeUriRecord(encodeUriRecord('tel:+15551234567')), 'tel:+15551234567');
      expect(decodeUriRecord(encodeUriRecord('mailto:someone@example.com')), 'mailto:someone@example.com');
    });

    test('decodeUriRecord returns null for a non-uri record', () {
      final record = encodeTextRecord('hi');
      expect(decodeUriRecord(record), isNull);
    });
  });

  group('describeRecord', () {
    test('classifies text records', () {
      final display = describeRecord(encodeTextRecord('note'));
      expect(display.kind, RecordKind.text);
      expect(display.detail, 'note');
    });

    test('classifies uri records', () {
      final display = describeRecord(encodeUriRecord('https://example.com'));
      expect(display.kind, RecordKind.uri);
      expect(display.detail, 'https://example.com');
    });

    test('falls back to a hex preview for unrecognized record types', () {
      final record = NdefRecord(
        typeNameFormat: TypeNameFormat.media,
        type: Uint8List.fromList(utf8.encode('text/plain')),
        identifier: Uint8List(0),
        payload: Uint8List.fromList(utf8.encode('raw')),
      );
      final display = describeRecord(record);
      expect(display.kind, RecordKind.other);
      expect(display.detail, isNot('raw'));
    });
  });
}

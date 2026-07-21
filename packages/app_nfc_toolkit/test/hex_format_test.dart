import 'package:app_nfc_toolkit/utils/hex_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('bytesToHex formats uppercase space-separated pairs', () {
    expect(bytesToHex([0xDE, 0xAD, 0xBE, 0xEF]), 'DE AD BE EF');
    expect(bytesToHex([1, 255]), '01 FF');
  });

  test('hexToBytes round-trips with bytesToHex', () {
    final bytes = [0x00, 0x1A, 0xFF, 0x42];
    expect(hexToBytes(bytesToHex(bytes)), bytes);
  });

  test('hexToBytes tolerates surrounding/extra whitespace', () {
    expect(hexToBytes(' DE AD  BE EF '), [0xDE, 0xAD, 0xBE, 0xEF]);
  });

  test('hexToBytes rejects odd-length input', () {
    expect(() => hexToBytes('ABC'), throwsFormatException);
  });
}

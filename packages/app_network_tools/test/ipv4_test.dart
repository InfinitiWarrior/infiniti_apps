import 'package:app_network_tools/utils/ipv4.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parseIPv4 packs octets big-endian', () {
    expect(parseIPv4('0.0.0.1'), 1);
    expect(parseIPv4('0.0.1.0'), 256);
    expect(parseIPv4('255.255.255.255'), 0xFFFFFFFF);
    expect(parseIPv4('192.168.1.1'), 0xC0A80101);
  });

  test('formatIPv4 is the inverse of parseIPv4', () {
    for (final address in ['0.0.0.0', '255.255.255.255', '192.168.1.1', '10.0.0.254']) {
      expect(formatIPv4(parseIPv4(address)), address);
    }
  });

  test('parseIPv4 rejects malformed input', () {
    expect(() => parseIPv4('1.2.3'), throwsFormatException);
    expect(() => parseIPv4('1.2.3.4.5'), throwsFormatException);
    expect(() => parseIPv4('1.2.3.256'), throwsFormatException);
    expect(() => parseIPv4('1.2.3.-1'), throwsFormatException);
    expect(() => parseIPv4('a.b.c.d'), throwsFormatException);
  });

  test('isValidIPv4', () {
    expect(isValidIPv4('192.168.1.1'), isTrue);
    expect(isValidIPv4('not an ip'), isFalse);
  });
}

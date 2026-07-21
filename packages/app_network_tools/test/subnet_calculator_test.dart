import 'package:app_network_tools/services/subnet_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('/24 network', () {
    final info = calculateSubnet('192.168.1.50', 24);

    expect(info.networkAddress, '192.168.1.0');
    expect(info.broadcastAddress, '192.168.1.255');
    expect(info.subnetMask, '255.255.255.0');
    expect(info.wildcardMask, '0.0.0.255');
    expect(info.firstHost, '192.168.1.1');
    expect(info.lastHost, '192.168.1.254');
    expect(info.totalAddresses, 256);
    expect(info.usableHostCount, 254);
  });

  test('/30 network (tiny point-to-point-ish subnet)', () {
    final info = calculateSubnet('10.0.0.5', 30);

    expect(info.networkAddress, '10.0.0.4');
    expect(info.broadcastAddress, '10.0.0.7');
    expect(info.firstHost, '10.0.0.5');
    expect(info.lastHost, '10.0.0.6');
    expect(info.totalAddresses, 4);
    expect(info.usableHostCount, 2);
  });

  test('/31 is a valid RFC 3021 point-to-point link (both addresses usable)', () {
    final info = calculateSubnet('10.0.0.0', 31);

    expect(info.networkAddress, '10.0.0.0');
    expect(info.broadcastAddress, '10.0.0.1');
    expect(info.firstHost, '10.0.0.0');
    expect(info.lastHost, '10.0.0.1');
    expect(info.totalAddresses, 2);
    expect(info.usableHostCount, 2);
  });

  test('/32 is a single host with no usable range', () {
    final info = calculateSubnet('10.0.0.5', 32);

    expect(info.networkAddress, '10.0.0.5');
    expect(info.broadcastAddress, '10.0.0.5');
    expect(info.firstHost, isNull);
    expect(info.lastHost, isNull);
    expect(info.totalAddresses, 1);
    expect(info.usableHostCount, 1);
  });

  test('/0 covers the entire address space', () {
    final info = calculateSubnet('10.0.0.5', 0);

    expect(info.networkAddress, '0.0.0.0');
    expect(info.broadcastAddress, '255.255.255.255');
    expect(info.subnetMask, '0.0.0.0');
    expect(info.totalAddresses, 4294967296);
  });

  test('an address not aligned to the prefix still resolves to the right network', () {
    final info = calculateSubnet('172.16.5.200', 20);
    expect(info.networkAddress, '172.16.0.0');
    expect(info.broadcastAddress, '172.16.15.255');
  });

  test('rejects an out-of-range prefix length', () {
    expect(() => calculateSubnet('10.0.0.1', -1), throwsArgumentError);
    expect(() => calculateSubnet('10.0.0.1', 33), throwsArgumentError);
  });

  test('rejects a malformed IP address', () {
    expect(() => calculateSubnet('not.an.ip', 24), throwsFormatException);
  });
}

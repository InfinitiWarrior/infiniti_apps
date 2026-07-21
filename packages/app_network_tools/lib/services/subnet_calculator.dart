import '../utils/ipv4.dart';

class SubnetInfo {
  const SubnetInfo({
    required this.networkAddress,
    required this.broadcastAddress,
    required this.subnetMask,
    required this.wildcardMask,
    required this.firstHost,
    required this.lastHost,
    required this.totalAddresses,
    required this.usableHostCount,
    required this.prefixLength,
  });

  final String networkAddress;
  final String broadcastAddress;
  final String subnetMask;
  final String wildcardMask;

  /// Null when the subnet has no usable host range (a /32).
  final String? firstHost;
  final String? lastHost;
  final int totalAddresses;
  final int usableHostCount;
  final int prefixLength;
}

/// Computes standard IPv4 CIDR subnet info. Pure arithmetic — no network
/// access, no platform dependency.
SubnetInfo calculateSubnet(String ipAddress, int prefixLength) {
  if (prefixLength < 0 || prefixLength > 32) {
    throw ArgumentError.value(prefixLength, 'prefixLength', 'Must be between 0 and 32.');
  }

  final ip = parseIPv4(ipAddress);
  final maskInt = prefixLength == 0 ? 0 : (0xFFFFFFFF << (32 - prefixLength)) & 0xFFFFFFFF;
  final wildcardInt = (~maskInt) & 0xFFFFFFFF;
  final network = ip & maskInt;
  final broadcast = network | wildcardInt;
  final totalAddresses = 1 << (32 - prefixLength);

  String? firstHost;
  String? lastHost;
  int usableHostCount;

  if (prefixLength == 32) {
    usableHostCount = 1;
  } else if (prefixLength == 31) {
    // RFC 3021 point-to-point link: both addresses are usable.
    usableHostCount = 2;
    firstHost = formatIPv4(network);
    lastHost = formatIPv4(broadcast);
  } else {
    usableHostCount = totalAddresses - 2;
    firstHost = formatIPv4(network + 1);
    lastHost = formatIPv4(broadcast - 1);
  }

  return SubnetInfo(
    networkAddress: formatIPv4(network),
    broadcastAddress: formatIPv4(broadcast),
    subnetMask: formatIPv4(maskInt),
    wildcardMask: formatIPv4(wildcardInt),
    firstHost: firstHost,
    lastHost: lastHost,
    totalAddresses: totalAddresses,
    usableHostCount: usableHostCount,
    prefixLength: prefixLength,
  );
}

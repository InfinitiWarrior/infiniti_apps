import 'dart:io';

/// Abstract so tests don't depend on real DNS resolution.
abstract class DnsService {
  Future<List<InternetAddress>> lookup(
    String host, {
    InternetAddressType type = InternetAddressType.any,
  });
}

class PlatformDnsService implements DnsService {
  @override
  Future<List<InternetAddress>> lookup(
    String host, {
    InternetAddressType type = InternetAddressType.any,
  }) {
    return InternetAddress.lookup(host, type: type);
  }
}

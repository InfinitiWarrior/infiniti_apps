import 'dart:async';
import 'dart:io';

class PortScanResult {
  const PortScanResult({required this.port, required this.isOpen});

  final int port;
  final bool isOpen;
}

/// Common TCP ports worth checking by default, roughly in the order a
/// network admin would care about them.
const commonPorts = <int>[
  21, 22, 23, 25, 53, 80, 110, 111, 135, 139, 143, 443, 445, 465, 587, 993,
  995, 1723, 3000, 3306, 3389, 5000, 5432, 5900, 6379, 8000, 8080, 8443,
  8888, 9000, 9090, 27017,
];

/// Abstract so tests don't open real sockets.
abstract class PortScannerService {
  /// Scans [ports] against [host], yielding one [PortScanResult] per port as
  /// each connection attempt resolves (not necessarily in port order, since
  /// probes run with limited concurrency).
  Stream<PortScanResult> scan(
    String host,
    List<int> ports, {
    Duration timeout = const Duration(seconds: 2),
  });
}

class PlatformPortScannerService implements PortScannerService {
  /// How many connection attempts run concurrently. High enough to scan a
  /// few dozen ports quickly, low enough not to look like a SYN flood.
  static const _concurrency = 16;

  @override
  Stream<PortScanResult> scan(
    String host,
    List<int> ports, {
    Duration timeout = const Duration(seconds: 2),
  }) async* {
    for (var i = 0; i < ports.length; i += _concurrency) {
      final batch = ports.skip(i).take(_concurrency);
      final results = await Future.wait(batch.map((port) => _checkPort(host, port, timeout)));
      for (final result in results) {
        yield result;
      }
    }
  }

  Future<PortScanResult> _checkPort(String host, int port, Duration timeout) async {
    try {
      final socket = await Socket.connect(host, port, timeout: timeout);
      socket.destroy();
      return PortScanResult(port: port, isOpen: true);
    } catch (_) {
      return PortScanResult(port: port, isOpen: false);
    }
  }
}

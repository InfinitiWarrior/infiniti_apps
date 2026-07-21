import 'package:dart_ping/dart_ping.dart';

import 'ping_service.dart';

class TracerouteHop {
  const TracerouteHop({
    required this.ttl,
    required this.address,
    required this.isDestination,
  });

  final int ttl;

  /// Null when this hop didn't respond in time (shown as "*" in classic
  /// traceroute output).
  final String? address;

  /// Whether [address] is the final target replying directly, rather than
  /// an intermediate router's TTL-exceeded response.
  final bool isDestination;
}

/// Traceroute implemented as a sequence of single pings with increasing TTL
/// — no raw sockets required, so it works identically on every platform
/// `dart_ping` supports (including Android, which has no `traceroute`
/// binary to shell out to, unlike desktop Linux).
class TracerouteService {
  TracerouteService(this._pingService);

  final PingService _pingService;

  Stream<TracerouteHop> traceroute(
    String host, {
    int maxHops = 30,
    int probeTimeoutSeconds = 2,
  }) async* {
    for (var ttl = 1; ttl <= maxHops; ttl++) {
      final hop = await _probeHop(host, ttl, probeTimeoutSeconds);
      yield hop;
      if (hop.isDestination) return;
    }
  }

  Future<TracerouteHop> _probeHop(String host, int ttl, int timeoutSeconds) async {
    await for (final event in _pingService.ping(
      host,
      count: 1,
      ttl: ttl,
      timeout: timeoutSeconds,
    )) {
      switch (event) {
        case PingResponse(:final ip):
          return TracerouteHop(ttl: ttl, address: ip, isDestination: true);
        case PingError(error: ErrorType.timeToLiveExceeded, :final ip):
          return TracerouteHop(ttl: ttl, address: ip, isDestination: false);
        case PingError():
          return TracerouteHop(ttl: ttl, address: null, isDestination: false);
        case PingSummary():
          // Reached the end of this single-probe run with no response/error
          // event above (shouldn't normally happen with count: 1, but handle
          // it rather than hang waiting for a stream that's about to close).
          return TracerouteHop(ttl: ttl, address: null, isDestination: false);
      }
    }
    return TracerouteHop(ttl: ttl, address: null, isDestination: false);
  }
}

import 'package:dart_ping/dart_ping.dart';

/// Abstract so widget/unit tests never spawn a real `ping` subprocess —
/// that's slow, network-dependent, and non-deterministic in CI-like runs,
/// the same reasoning that keeps other apps' platform plugins behind an
/// interface (see CLAUDE.md's DI pattern for platform wrappers).
abstract class PingService {
  /// [interval] and [timeout] are in seconds, matching `dart_ping`'s own API.
  Stream<PingEvent> ping(
    String host, {
    int? count,
    int interval = 1,
    int timeout = 2,
    int ttl = 255,
  });
}

class PlatformPingService implements PingService {
  @override
  Stream<PingEvent> ping(
    String host, {
    int? count,
    int interval = 1,
    int timeout = 2,
    int ttl = 255,
  }) {
    return Ping(
      host,
      count: count,
      interval: interval,
      timeout: timeout,
      ttl: ttl,
    ).stream;
  }
}

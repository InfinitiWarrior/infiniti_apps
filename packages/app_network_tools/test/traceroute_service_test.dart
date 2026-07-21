import 'package:app_network_tools/services/ping_service.dart';
import 'package:app_network_tools/services/traceroute_service.dart';
import 'package:dart_ping/dart_ping.dart';
import 'package:flutter_test/flutter_test.dart';

/// Emits one scripted event per TTL, keyed by the ttl the caller requested —
/// mirroring how a real hop-by-hop traceroute probe behaves.
class _ScriptedPingService implements PingService {
  _ScriptedPingService(this.eventsByTtl);

  final Map<int, PingEvent> eventsByTtl;
  final List<int> requestedTtls = [];

  @override
  Stream<PingEvent> ping(
    String host, {
    int? count,
    int interval = 1,
    int timeout = 2,
    int ttl = 255,
  }) async* {
    requestedTtls.add(ttl);
    final event = eventsByTtl[ttl];
    if (event != null) yield event;
  }
}

void main() {
  test('stops at the hop that returns the actual destination', () async {
    final fake = _ScriptedPingService({
      1: const PingError(ErrorType.timeToLiveExceeded, ip: '10.0.0.1'),
      2: const PingError(ErrorType.timeToLiveExceeded, ip: '10.0.0.2'),
      3: const PingResponse(ip: '93.184.216.34', seq: 0),
    });
    final service = TracerouteService(fake);

    final hops = await service.traceroute('example.com', maxHops: 30).toList();

    expect(hops, hasLength(3));
    expect(hops[0].address, '10.0.0.1');
    expect(hops[0].isDestination, isFalse);
    expect(hops[1].address, '10.0.0.2');
    expect(hops[2].address, '93.184.216.34');
    expect(hops[2].isDestination, isTrue);
    expect(fake.requestedTtls, [1, 2, 3]);
  });

  test('records a "*" hop for a probe that times out', () async {
    final fake = _ScriptedPingService({
      1: const PingError(ErrorType.requestTimedOut),
      2: const PingResponse(ip: '1.1.1.1', seq: 0),
    });
    final service = TracerouteService(fake);

    final hops = await service.traceroute('1.1.1.1', maxHops: 30).toList();

    expect(hops[0].address, isNull);
    expect(hops[0].isDestination, isFalse);
    expect(hops[1].isDestination, isTrue);
  });

  test('gives up after maxHops without reaching the destination', () async {
    final fake = _ScriptedPingService({}); // every ttl times out (no scripted event)
    final service = TracerouteService(fake);

    final hops = await service.traceroute('unreachable.example', maxHops: 5).toList();

    expect(hops, hasLength(5));
    expect(hops.every((h) => !h.isDestination), isTrue);
  });
}

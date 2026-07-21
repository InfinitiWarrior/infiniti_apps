import 'dart:async';
import 'dart:convert';
import 'dart:io';

const defaultWhoisServer = 'whois.iana.org';

/// IANA's whois server usually just returns a referral (a `refer:`/`whois:`
/// line naming the registry that actually holds the record) rather than
/// registrant details — pure text parsing, no I/O, so it's independently
/// testable.
String? extractWhoisReferral(String response) {
  for (final rawLine in response.split('\n')) {
    final line = rawLine.trim();
    final lower = line.toLowerCase();
    if (lower.startsWith('refer:') || lower.startsWith('whois:')) {
      final value = line.substring(line.indexOf(':') + 1).trim();
      if (value.isNotEmpty) return value;
    }
  }
  return null;
}

/// Abstract so tests don't open a real socket to a whois server.
abstract class WhoisService {
  /// Looks up [domain]. Queries [defaultWhoisServer] first and, unless
  /// [server] pins a specific one, follows a single referral to the
  /// authoritative registry for a fuller result.
  Future<String> lookup(String domain, {String? server});
}

class PlatformWhoisService implements WhoisService {
  @override
  Future<String> lookup(String domain, {String? server}) async {
    final firstServer = server ?? defaultWhoisServer;
    final firstResponse = await _query(firstServer, domain);
    if (server != null) return firstResponse;

    final referredServer = extractWhoisReferral(firstResponse);
    if (referredServer == null || referredServer == firstServer) {
      return firstResponse;
    }

    try {
      final secondResponse = await _query(referredServer, domain);
      return '$firstResponse\n\n--- $referredServer ---\n\n$secondResponse';
    } catch (_) {
      return firstResponse;
    }
  }

  Future<String> _query(String host, String domain) async {
    final socket = await Socket.connect(host, 43, timeout: const Duration(seconds: 10));
    final buffer = StringBuffer();
    final completer = Completer<String>();
    socket.listen(
      (data) => buffer.write(utf8.decode(data, allowMalformed: true)),
      onDone: () => completer.complete(buffer.toString()),
      onError: completer.completeError,
      cancelOnError: true,
    );
    socket.write('$domain\r\n');
    await socket.flush();
    try {
      return await completer.future;
    } finally {
      await socket.close();
    }
  }
}

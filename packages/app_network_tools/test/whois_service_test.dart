import 'package:app_network_tools/services/whois_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('extractWhoisReferral', () {
    test('finds a "refer:" line', () {
      const response = '''
% IANA WHOIS server
refer:        whois.verisign-grs.com

domain:       COM
''';
      expect(extractWhoisReferral(response), 'whois.verisign-grs.com');
    });

    test('finds a "whois:" line when there is no "refer:" line', () {
      const response = '''
domain:       EXAMPLE
whois:        whois.example-registry.net
''';
      expect(extractWhoisReferral(response), 'whois.example-registry.net');
    });

    test('is case-insensitive on the field name', () {
      const response = 'REFER: whois.example.com';
      expect(extractWhoisReferral(response), 'whois.example.com');
    });

    test('returns null when there is no referral', () {
      const response = 'domain: EXAMPLE.COM\nstatus: active\n';
      expect(extractWhoisReferral(response), isNull);
    });

    test('ignores an empty referral value', () {
      const response = 'refer:   \nstatus: active\n';
      expect(extractWhoisReferral(response), isNull);
    });
  });
}

import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FileSizeFormatter', () {
    test('formats bytes into human-readable units', () {
      expect(FileSizeFormatter.format(0), '0 B');
      expect(FileSizeFormatter.format(512), '512 B');
      expect(FileSizeFormatter.format(1536), '1.5 KB');
      expect(FileSizeFormatter.format(1048576), '1.0 MB');
    });
  });

  group('StringCasing', () {
    test('capitalizes the first letter', () {
      expect('hello'.capitalized, 'Hello');
      expect(''.capitalized, '');
    });

    test('truncates long strings with an ellipsis', () {
      expect('hello world'.truncate(5), 'hello…');
      expect('hi'.truncate(5), 'hi');
    });
  });
}

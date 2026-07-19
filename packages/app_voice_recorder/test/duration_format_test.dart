import 'package:app_voice_recorder/utils/duration_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats under an hour as mm:ss', () {
    expect(formatDuration(const Duration(seconds: 5)), '00:05');
    expect(formatDuration(const Duration(minutes: 2, seconds: 34)), '02:34');
  });

  test('includes hours once elapsed exceeds 60 minutes', () {
    expect(
      formatDuration(const Duration(hours: 1, minutes: 2, seconds: 3)),
      '1:02:03',
    );
  });
}

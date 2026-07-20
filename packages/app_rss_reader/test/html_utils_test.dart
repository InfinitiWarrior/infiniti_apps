import 'package:app_rss_reader/utils/html_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('strips tags and converts common entities', () {
    const html = '<p>Hello &amp; <b>world</b>.</p><p>Second paragraph.</p>';
    expect(stripHtml(html), 'Hello & world.\n\nSecond paragraph.');
  });

  test('converts <br> to newlines', () {
    const html = 'Line one<br/>Line two';
    expect(stripHtml(html), 'Line one\nLine two');
  });
}

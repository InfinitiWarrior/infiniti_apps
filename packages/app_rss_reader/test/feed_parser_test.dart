import 'package:app_rss_reader/services/feed_parser.dart';
import 'package:flutter_test/flutter_test.dart';

const _rssXml = '''
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
  <channel>
    <title>Example Blog</title>
    <link>https://example.com</link>
    <description>An example feed</description>
    <item>
      <title>First Post</title>
      <link>https://example.com/first-post</link>
      <guid>https://example.com/first-post</guid>
      <description>&lt;p&gt;Hello &lt;b&gt;world&lt;/b&gt;.&lt;/p&gt;</description>
      <pubDate>Mon, 01 Jan 2024 12:00:00 GMT</pubDate>
      <author>jane@example.com (Jane Doe)</author>
    </item>
    <item>
      <title>Second Post</title>
      <link>https://example.com/second-post</link>
      <guid>https://example.com/second-post</guid>
      <description>Plain text summary.</description>
      <pubDate>Tue, 02 Jan 2024 08:30:00 GMT</pubDate>
    </item>
  </channel>
</rss>
''';

const _atomXml = '''
<?xml version="1.0" encoding="UTF-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
  <title>Example Atom Feed</title>
  <id>https://example.com/atom</id>
  <updated>2024-01-01T12:00:00Z</updated>
  <entry>
    <title>Atom Entry</title>
    <id>https://example.com/atom/1</id>
    <link href="https://example.com/atom/1"/>
    <published>2024-01-01T12:00:00Z</published>
    <summary>An atom summary.</summary>
  </entry>
</feed>
''';

void main() {
  test('parses RSS 2.0 feeds', () {
    final parsed = parseFeedXml(_rssXml);

    expect(parsed.title, 'Example Blog');
    expect(parsed.articles, hasLength(2));

    final first = parsed.articles.first;
    expect(first.title, 'First Post');
    expect(first.guid, 'https://example.com/first-post');
    expect(first.link, 'https://example.com/first-post');
    expect(first.summary, contains('Hello'));
    expect(first.publishedAt, DateTime.utc(2024, 1, 1, 12));
  });

  test('parses Atom feeds', () {
    final parsed = parseFeedXml(_atomXml);

    expect(parsed.title, 'Example Atom Feed');
    expect(parsed.articles, hasLength(1));

    final entry = parsed.articles.single;
    expect(entry.title, 'Atom Entry');
    expect(entry.guid, 'https://example.com/atom/1');
    expect(entry.link, 'https://example.com/atom/1');
    expect(entry.summary, 'An atom summary.');
    expect(entry.publishedAt, DateTime.utc(2024, 1, 1, 12));
  });

  test('falls back to link when guid is missing', () {
    const xml = '''
<rss version="2.0">
  <channel>
    <title>No Guid Feed</title>
    <item>
      <title>Only a link</title>
      <link>https://example.com/only-link</link>
      <description>desc</description>
    </item>
  </channel>
</rss>
''';
    final parsed = parseFeedXml(xml);
    expect(parsed.articles.single.guid, 'https://example.com/only-link');
  });
}

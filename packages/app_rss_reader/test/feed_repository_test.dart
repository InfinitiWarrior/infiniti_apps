import 'package:app_rss_reader/database/rss_database.dart';
import 'package:app_rss_reader/repositories/feed_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _feedXml = '''
<rss version="2.0">
  <channel>
    <title>Example Blog</title>
    <item>
      <title>First Post</title>
      <link>https://example.com/first-post</link>
      <guid>https://example.com/first-post</guid>
      <description>desc</description>
      <pubDate>Mon, 01 Jan 2024 12:00:00 GMT</pubDate>
    </item>
  </channel>
</rss>
''';

void main() {
  test('addFeed fetches, parses, and stores the feed plus its articles', () async {
    final database = RssDatabase.forTesting(NativeDatabase.memory());
    final client = MockClient((request) async => http.Response(_feedXml, 200));
    final repository = FeedRepository(database, httpClient: client);

    final feed = await repository.addFeed('https://example.com/feed.xml');
    expect(feed.title, 'Example Blog');

    final articles = await repository.watchArticles(feedId: feed.id).first;
    expect(articles, hasLength(1));
    expect(articles.single.article.title, 'First Post');

    repository.dispose();
    await database.close();
  });

  test('refreshFeed records the error on the feed instead of throwing', () async {
    final database = RssDatabase.forTesting(NativeDatabase.memory());
    final okClient = MockClient((request) async => http.Response(_feedXml, 200));
    final repository = FeedRepository(database, httpClient: okClient);
    final feed = await repository.addFeed('https://example.com/feed.xml');
    repository.dispose();

    final failingClient = MockClient((request) async => http.Response('not found', 404));
    final failingRepository = FeedRepository(database, httpClient: failingClient);

    await failingRepository.refreshFeed(feed);

    final feeds = await database.watchFeeds().first;
    expect(feeds.single.lastError, isNotNull);

    failingRepository.dispose();
    await database.close();
  });
}

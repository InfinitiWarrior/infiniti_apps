import 'package:app_rss_reader/database/rss_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late RssDatabase database;

  setUp(() {
    database = RssDatabase.forTesting(NativeDatabase.memory());
  });

  test('addFeed inserts a feed and insertNewArticles dedupes by guid', () async {
    final feed = await database.addFeed(url: 'https://example.com/feed.xml', title: 'Example');
    expect(feed.category, 'Uncategorized');

    final articleA = ArticlesCompanion.insert(
      feedId: feed.id,
      guid: 'a',
      title: 'Article A',
    );
    final articleB = ArticlesCompanion.insert(
      feedId: feed.id,
      guid: 'b',
      title: 'Article B',
    );

    await database.insertNewArticles(feed.id, [articleA, articleB]);
    // Re-inserting the same guids should not create duplicates.
    await database.insertNewArticles(feed.id, [articleA]);

    final articles = await database.watchArticles(feedId: feed.id).first;
    expect(articles, hasLength(2));

    await database.close();
  });

  test('setRead and watchUnreadCount track read state', () async {
    final feed = await database.addFeed(url: 'https://example.com/feed.xml', title: 'Example');
    await database.insertNewArticles(feed.id, [
      ArticlesCompanion.insert(feedId: feed.id, guid: 'a', title: 'A'),
      ArticlesCompanion.insert(feedId: feed.id, guid: 'b', title: 'B'),
    ]);

    expect(await database.watchUnreadCount(feedId: feed.id).first, 2);

    final articles = await database.watchArticles(feedId: feed.id).first;
    await database.setRead(articles.first.article.id, true);

    expect(await database.watchUnreadCount(feedId: feed.id).first, 1);

    await database.markAllRead(feedId: feed.id);
    expect(await database.watchUnreadCount(feedId: feed.id).first, 0);

    await database.close();
  });

  test('deleteFeed cascades to its articles', () async {
    final feed = await database.addFeed(url: 'https://example.com/feed.xml', title: 'Example');
    await database.insertNewArticles(feed.id, [
      ArticlesCompanion.insert(feedId: feed.id, guid: 'a', title: 'A'),
    ]);

    await database.deleteFeed(feed.id);

    final articles = await database.watchArticles().first;
    expect(articles, isEmpty);

    await database.close();
  });
}

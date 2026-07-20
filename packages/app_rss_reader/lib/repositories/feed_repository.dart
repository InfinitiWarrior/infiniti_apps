import 'package:core/core.dart';
import 'package:drift/drift.dart' show Value;
import 'package:http/http.dart' as http;

import '../database/rss_database.dart';
import '../services/feed_parser.dart';

class FeedRepository {
  FeedRepository(this._database, {http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  final RssDatabase _database;
  final http.Client _httpClient;

  Stream<List<Feed>> watchFeeds() => _database.watchFeeds();

  Stream<List<ArticleWithFeed>> watchArticles({int? feedId, bool unreadOnly = false}) {
    return _database.watchArticles(feedId: feedId, unreadOnly: unreadOnly);
  }

  Stream<int> watchUnreadCount({int? feedId}) => _database.watchUnreadCount(feedId: feedId);

  /// Fetches [url] to validate it and discover the feed's title, then saves
  /// it and does an initial article fetch.
  Future<Feed> addFeed(String url, {String? category}) async {
    final xmlBody = await _fetchXml(url);
    final parsed = parseFeedXml(xmlBody);
    final feed = await _database.addFeed(url: url, title: parsed.title, category: category);
    await _saveArticles(feed.id, parsed.articles);
    await _database.markFeedFetched(feed.id);
    return feed;
  }

  Future<void> removeFeed(int feedId) => _database.deleteFeed(feedId);

  Future<void> setCategory(int feedId, String category) {
    return _database.updateFeedCategory(feedId, category);
  }

  /// Re-fetches a single feed and stores any new articles. Failures are
  /// recorded on the feed row (surfaced in the UI) rather than thrown, so a
  /// batch refresh of many feeds can't be aborted by one bad feed.
  Future<void> refreshFeed(Feed feed) async {
    try {
      final xmlBody = await _fetchXml(feed.url);
      final parsed = parseFeedXml(xmlBody);
      await _saveArticles(feed.id, parsed.articles);
      await _database.markFeedFetched(feed.id);
    } catch (e) {
      AppLogger.warning('Failed to refresh feed ${feed.url}: $e');
      await _database.markFeedFetched(feed.id, error: e.toString());
    }
  }

  Future<void> refreshAll() async {
    final feeds = await _database.watchFeeds().first;
    for (final feed in feeds) {
      await refreshFeed(feed);
    }
  }

  Future<void> setRead(int articleId, bool isRead) => _database.setRead(articleId, isRead);

  Future<void> markAllRead({int? feedId}) => _database.markAllRead(feedId: feedId);

  Future<String> _fetchXml(String url) async {
    final response = await _httpClient.get(Uri.parse(url));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('HTTP ${response.statusCode} fetching $url');
    }
    return response.body;
  }

  Future<void> _saveArticles(int feedId, List<ParsedArticle> parsedArticles) {
    final companions = parsedArticles
        .where((a) => a.guid.isNotEmpty)
        .map(
          (a) => ArticlesCompanion.insert(
            feedId: feedId,
            guid: a.guid,
            title: a.title,
            link: Value(a.link),
            summary: Value(a.summary),
            content: Value(a.content),
            author: Value(a.author),
            publishedAt: Value(a.publishedAt),
          ),
        )
        .toList();
    return _database.insertNewArticles(feedId, companions);
  }

  void dispose() => _httpClient.close();
}

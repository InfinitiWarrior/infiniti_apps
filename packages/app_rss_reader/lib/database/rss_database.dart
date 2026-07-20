import 'package:core/core.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;

part 'rss_database.g.dart';

class Feeds extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get url => text().unique()();
  TextColumn get title => text()();
  TextColumn get category => text().withDefault(const Constant('Uncategorized'))();
  DateTimeColumn get addedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastFetchedAt => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();
}

class Articles extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get feedId => integer().references(Feeds, #id, onDelete: KeyAction.cascade)();
  TextColumn get guid => text()();
  TextColumn get title => text()();
  TextColumn get link => text().nullable()();
  TextColumn get summary => text().nullable()();
  TextColumn get content => text().nullable()();
  TextColumn get author => text().nullable()();
  DateTimeColumn get publishedAt => dateTime().nullable()();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  DateTimeColumn get fetchedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {feedId, guid},
  ];
}

class ArticleWithFeed {
  ArticleWithFeed({required this.article, required this.feed});

  final Article article;
  final Feed feed;
}

@DriftDatabase(tables: [Feeds, Articles])
class RssDatabase extends _$RssDatabase {
  RssDatabase() : super(openAppConnection('rss_reader.sqlite'));

  @visibleForTesting
  RssDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  Stream<List<Feed>> watchFeeds() {
    return (select(feeds)..orderBy([(t) => OrderingTerm.asc(t.title)])).watch();
  }

  Future<Feed> addFeed({required String url, required String title, String? category}) async {
    final id = await into(feeds).insert(
      FeedsCompanion.insert(
        url: url,
        title: title,
        category: Value(category ?? 'Uncategorized'),
      ),
    );
    return (select(feeds)..where((t) => t.id.equals(id))).getSingle();
  }

  Future<void> updateFeedCategory(int feedId, String category) {
    return (update(feeds)..where((t) => t.id.equals(feedId))).write(
      FeedsCompanion(category: Value(category)),
    );
  }

  Future<void> markFeedFetched(int feedId, {String? error}) {
    return (update(feeds)..where((t) => t.id.equals(feedId))).write(
      FeedsCompanion(
        lastFetchedAt: Value(DateTime.now()),
        lastError: Value(error),
      ),
    );
  }

  Future<void> deleteFeed(int feedId) {
    return (delete(feeds)..where((t) => t.id.equals(feedId))).go();
  }

  /// Inserts new articles for a feed, skipping ones that already exist
  /// (matched by feedId+guid). Returns how many were newly inserted.
  Future<int> insertNewArticles(int feedId, List<ArticlesCompanion> incoming) async {
    var inserted = 0;
    await batch((b) {
      for (final article in incoming) {
        b.insert(articles, article, mode: InsertMode.insertOrIgnore);
      }
    });
    final guids = incoming.map((a) => a.guid.value).toSet();
    final existing = await (select(articles)
          ..where((t) => t.feedId.equals(feedId) & t.guid.isIn(guids)))
        .get();
    inserted = existing.length;
    return inserted;
  }

  Stream<List<ArticleWithFeed>> watchArticles({int? feedId, bool unreadOnly = false}) {
    final query = select(articles).join([
      innerJoin(feeds, feeds.id.equalsExp(articles.feedId)),
    ]);
    if (feedId != null) {
      query.where(articles.feedId.equals(feedId));
    }
    if (unreadOnly) {
      query.where(articles.isRead.equals(false));
    }
    query.orderBy([OrderingTerm.desc(articles.publishedAt)]);
    return query.watch().map(
      (rows) => rows
          .map(
            (row) => ArticleWithFeed(
              article: row.readTable(articles),
              feed: row.readTable(feeds),
            ),
          )
          .toList(),
    );
  }

  Future<void> setRead(int articleId, bool isRead) {
    return (update(articles)..where((t) => t.id.equals(articleId))).write(
      ArticlesCompanion(isRead: Value(isRead)),
    );
  }

  Future<void> markAllRead({int? feedId}) {
    final query = update(articles);
    if (feedId != null) {
      query.where((t) => t.feedId.equals(feedId));
    }
    return query.write(const ArticlesCompanion(isRead: Value(true)));
  }

  Stream<int> watchUnreadCount({int? feedId}) {
    final query = selectOnly(articles)..addColumns([articles.id.count()]);
    query.where(articles.isRead.equals(false));
    if (feedId != null) {
      query.where(articles.feedId.equals(feedId));
    }
    return query.map((row) => row.read(articles.id.count()) ?? 0).watchSingle();
  }
}

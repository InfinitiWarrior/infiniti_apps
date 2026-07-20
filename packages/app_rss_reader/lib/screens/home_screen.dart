import 'package:collection/collection.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../database/rss_database.dart';
import '../repositories/feed_repository.dart';
import '../widgets/article_tile.dart';
import '../widgets/feed_drawer.dart';
import 'article_detail_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.repository});

  final FeedRepository repository;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? _selectedFeedId;
  bool _unreadOnly = false;

  // Cached rather than created inline in build(): a join query has no stable
  // cache key in drift, so a fresh Stream object on every rebuild makes
  // StreamBuilder cancel and resubscribe on every frame, which leaves
  // orphaned listeners behind and can deadlock RssDatabase.close() in tests.
  late Stream<List<Feed>> _feedsStream;
  late Stream<List<ArticleWithFeed>> _articlesStream;

  @override
  void initState() {
    super.initState();
    _feedsStream = widget.repository.watchFeeds();
    _updateArticlesStream();
  }

  void _updateArticlesStream() {
    _articlesStream = widget.repository.watchArticles(
      feedId: _selectedFeedId,
      unreadOnly: _unreadOnly,
    );
  }

  void _selectFeed(int? feedId) {
    setState(() {
      _selectedFeedId = feedId;
      _updateArticlesStream();
    });
  }

  void _toggleUnreadOnly() {
    setState(() {
      _unreadOnly = !_unreadOnly;
      _updateArticlesStream();
    });
  }

  Future<void> _refresh() async {
    final feeds = await widget.repository.watchFeeds().first;
    final feed = _selectedFeedId == null
        ? null
        : feeds.where((f) => f.id == _selectedFeedId).firstOrNull;
    if (feed != null) {
      await widget.repository.refreshFeed(feed);
    } else {
      await widget.repository.refreshAll();
    }
  }

  Future<void> _openArticle(ArticleWithFeed entry) async {
    if (!entry.article.isRead) {
      await widget.repository.setRead(entry.article.id, true);
    }
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ArticleDetailScreen(entry: entry)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Feed>>(
      stream: _feedsStream,
      builder: (context, feedsSnapshot) {
        final feeds = feedsSnapshot.data ?? const <Feed>[];
        final selectedFeed = _selectedFeedId == null
            ? null
            : feeds.where((f) => f.id == _selectedFeedId).firstOrNull;

        return Scaffold(
          appBar: InfinitiAppBar(
            title: selectedFeed?.title ?? 'All Articles',
            actions: [
              IconButton(
                icon: Icon(_unreadOnly ? Icons.mark_email_unread : Icons.mark_email_read),
                tooltip: _unreadOnly ? 'Showing unread only' : 'Showing all articles',
                onPressed: _toggleUnreadOnly,
              ),
            ],
          ),
          drawer: FeedDrawer(
            repository: widget.repository,
            feeds: feeds,
            selectedFeedId: _selectedFeedId,
            onSelectFeed: (feedId) {
              _selectFeed(feedId);
              Navigator.of(context).pop();
            },
            onOpenSettings: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SettingsScreen(repository: widget.repository),
                ),
              );
            },
          ),
          body: RefreshIndicator(
            onRefresh: _refresh,
            child: StreamBuilder<List<ArticleWithFeed>>(
              stream: _articlesStream,
              builder: (context, snapshot) {
                final entries = snapshot.data ?? const <ArticleWithFeed>[];
                if (entries.isEmpty) {
                  return LayoutBuilder(
                    builder: (context, constraints) => SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: constraints.maxHeight,
                        child: EmptyState(
                          icon: Icons.rss_feed,
                          message: feeds.isEmpty
                              ? 'No feeds yet. Open the menu to add one.'
                              : _unreadOnly
                              ? 'No unread articles.'
                              : 'No articles yet. Pull down to refresh.',
                        ),
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  itemCount: entries.length,
                  separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return ArticleTile(entry: entry, onTap: () => _openArticle(entry));
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}

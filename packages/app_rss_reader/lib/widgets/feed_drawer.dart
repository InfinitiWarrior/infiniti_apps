import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../database/rss_database.dart';
import '../repositories/feed_repository.dart';
import 'add_feed_dialog.dart';

class FeedDrawer extends StatelessWidget {
  const FeedDrawer({
    super.key,
    required this.repository,
    required this.feeds,
    required this.selectedFeedId,
    required this.onSelectFeed,
    required this.onOpenSettings,
  });

  final FeedRepository repository;

  /// Passed down from the parent's own [FeedRepository.watchFeeds]
  /// subscription rather than re-subscribed here — two concurrent listeners
  /// on the identical query deadlocks drift's `close()` (see rss_database
  /// close()-hang note in CLAUDE.md).
  final List<Feed> feeds;
  final int? selectedFeedId;
  final ValueChanged<int?> onSelectFeed;
  final VoidCallback onOpenSettings;

  Future<void> _addFeed(BuildContext context) async {
    final result = await showAddFeedDialog(context);
    if (result == null || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await repository.addFeed(result.url, category: result.category);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Could not add feed: $e')));
    }
  }

  Future<void> _confirmDelete(BuildContext context, Feed feed) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove feed?'),
        content: Text('This removes "${feed.title}" and its cached articles.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await repository.removeFeed(feed.id);
      if (selectedFeedId == feed.id) {
        onSelectFeed(null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  const Expanded(child: Text('Feeds', style: AppTextStyles.headline)),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    tooltip: 'Settings',
                    onPressed: onOpenSettings,
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.all_inbox_outlined),
              title: const Text('All articles'),
              selected: selectedFeedId == null,
              onTap: () => onSelectFeed(null),
            ),
            const Divider(height: 1),
            Expanded(
              child: feeds.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: Text(
                        'No feeds yet. Tap "Add feed" below to subscribe to one.',
                        style: AppTextStyles.bodyMuted,
                      ),
                    )
                  : ListView.builder(
                      itemCount: feeds.length,
                      itemBuilder: (context, index) {
                        final feed = feeds[index];
                        return _FeedListTile(
                          key: ValueKey(feed.id),
                          repository: repository,
                          feed: feed,
                          selected: selectedFeedId == feed.id,
                          onTap: () => onSelectFeed(feed.id),
                          onDelete: () => _confirmDelete(context, feed),
                        );
                      },
                    ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Add feed'),
              onTap: () => _addFeed(context),
            ),
          ],
        ),
      ),
    );
  }
}

/// Stateful so its unread-count stream is created once (in [initState]) and
/// kept stable across parent rebuilds — recreating it inline in a builder
/// would cancel/resubscribe on every rebuild. The [ValueKey] on the feed id
/// in [FeedDrawer]'s [ListView.builder] keeps this widget's state (and thus
/// its stream) tied to that specific feed rather than list position.
class _FeedListTile extends StatefulWidget {
  const _FeedListTile({
    super.key,
    required this.repository,
    required this.feed,
    required this.selected,
    required this.onTap,
    required this.onDelete,
  });

  final FeedRepository repository;
  final Feed feed;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  State<_FeedListTile> createState() => _FeedListTileState();
}

class _FeedListTileState extends State<_FeedListTile> {
  late final Stream<int> _unreadStream = widget.repository.watchUnreadCount(
    feedId: widget.feed.id,
  );

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: _unreadStream,
      builder: (context, unreadSnapshot) {
        final unread = unreadSnapshot.data ?? 0;
        return ListTile(
          leading: const Icon(Icons.rss_feed),
          title: Text(widget.feed.title, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(widget.feed.category),
          selected: widget.selected,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (unread > 0)
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.xs),
                  child: Text(
                    '$unread',
                    style: AppTextStyles.caption.copyWith(color: AppColors.primary),
                  ),
                ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') widget.onDelete();
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'delete', child: Text('Remove')),
                ],
              ),
            ],
          ),
          onTap: widget.onTap,
        );
      },
    );
  }
}

import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../database/music_database.dart';
import '../utils/duration_format.dart';

class TrackTile extends StatelessWidget {
  const TrackTile({
    super.key,
    required this.track,
    required this.isCurrent,
    required this.onTap,
    this.onLongPress,
    this.selectionMode = false,
    this.selected = false,
    this.onAddToQueue,
    this.onAddToPlaylist,
    this.onDelete,
    this.trailing,
  });

  final Track track;
  final bool isCurrent;
  final VoidCallback onTap;

  /// Starts/extends multi-select mode in the containing list, e.g. Library.
  final VoidCallback? onLongPress;

  /// Whether the containing list is currently in multi-select mode — swaps
  /// the leading icon for a checkbox and hides the per-row overflow menu,
  /// since bulk actions live in the list's app bar instead.
  final bool selectionMode;
  final bool selected;

  final VoidCallback? onAddToQueue;
  final VoidCallback? onAddToPlaylist;

  /// Shown as "Delete" in the overflow menu. For device-scanned tracks the
  /// callback routes through the OS's own scoped-storage confirmation
  /// dialog rather than a custom one — see `LibraryScreen._deleteTrack`.
  final VoidCallback? onDelete;

  /// Overrides the default overflow menu, e.g. a "remove" action in a
  /// playlist/queue detail screen.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Row(
        children: [
          if (selectionMode)
            Checkbox(value: selected, onChanged: (_) => onTap())
          else
            Icon(
              isCurrent ? Icons.volume_up : Icons.music_note,
              color: isCurrent ? AppColors.mauve : AppColors.subtext0,
            ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track.title,
                  style: isCurrent
                      ? AppTextStyles.body.copyWith(color: AppColors.mauve)
                      : AppTextStyles.body,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    if (track.artist != null) track.artist!,
                    formatDuration(Duration(milliseconds: track.durationMs)),
                  ].join(' · '),
                  style: AppTextStyles.bodyMuted,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (!selectionMode) trailing ?? _defaultMenu(context),
        ],
      ),
    );
  }

  Widget _defaultMenu(BuildContext context) {
    if (onAddToQueue == null && onAddToPlaylist == null && onDelete == null) {
      return const SizedBox.shrink();
    }
    return PopupMenuButton<void>(
      icon: const Icon(Icons.more_vert),
      itemBuilder: (context) => [
        if (onAddToQueue != null)
          PopupMenuItem(
            onTap: onAddToQueue,
            child: const Text('Add to queue'),
          ),
        if (onAddToPlaylist != null)
          PopupMenuItem(
            onTap: onAddToPlaylist,
            child: const Text('Add to playlist'),
          ),
        if (onDelete != null)
          PopupMenuItem(
            onTap: onDelete,
            child: const Row(
              children: [
                Icon(Icons.delete_outline, color: AppColors.red),
                SizedBox(width: AppSpacing.sm),
                Text('Delete'),
              ],
            ),
          ),
      ],
    );
  }
}

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
    this.onAddToQueue,
    this.onAddToPlaylist,
    this.trailing,
  });

  final Track track;
  final bool isCurrent;
  final VoidCallback onTap;
  final VoidCallback? onAddToQueue;
  final VoidCallback? onAddToPlaylist;

  /// Overrides the default overflow menu, e.g. a "remove" action in a
  /// playlist/queue detail screen.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
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
          trailing ?? _defaultMenu(context),
        ],
      ),
    );
  }

  Widget _defaultMenu(BuildContext context) {
    if (onAddToQueue == null && onAddToPlaylist == null) {
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
      ],
    );
  }
}

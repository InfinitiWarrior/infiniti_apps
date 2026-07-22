import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../database/music_database.dart';

class PlaylistTile extends StatelessWidget {
  const PlaylistTile({
    super.key,
    required this.playlist,
    required this.onTap,
    required this.onDelete,
  });

  final Playlist playlist;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          const Icon(Icons.queue_music, color: AppColors.subtext0),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              playlist.name,
              style: AppTextStyles.body,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete playlist',
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

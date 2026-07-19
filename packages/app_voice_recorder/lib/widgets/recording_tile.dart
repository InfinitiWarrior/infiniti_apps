import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../database/recorder_database.dart';
import '../utils/duration_format.dart';

class RecordingTile extends StatelessWidget {
  const RecordingTile({
    super.key,
    required this.recording,
    required this.isPlaying,
    required this.playbackPosition,
    required this.onPlayToggle,
    required this.onRename,
    required this.onDelete,
  });

  final Recording recording;
  final bool isPlaying;
  final Duration playbackPosition;
  final VoidCallback onPlayToggle;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final totalDuration = Duration(milliseconds: recording.durationMs);
    final progress = totalDuration.inMilliseconds == 0
        ? 0.0
        : (playbackPosition.inMilliseconds / totalDuration.inMilliseconds).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        onTap: onPlayToggle,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                  color: AppColors.primary,
                  size: 36,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recording.displayName,
                        style: AppTextStyles.body,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${formatDuration(totalDuration)} · ${recording.format.toUpperCase()} · '
                        '${recording.createdAt.relative}',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  color: AppColors.surface1,
                  icon: const Icon(Icons.more_vert, color: AppColors.subtext0),
                  onSelected: (value) {
                    if (value == 'rename') onRename();
                    if (value == 'delete') onDelete();
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'rename', child: Text('Rename')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
            if (isPlaying) ...[
              const SizedBox(height: AppSpacing.xs),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 4,
                  backgroundColor: AppColors.surface0,
                  color: AppColors.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

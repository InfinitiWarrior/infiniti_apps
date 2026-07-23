import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../database/music_database.dart';
import '../services/download_format.dart';

class DownloadTaskTile extends StatelessWidget {
  const DownloadTaskTile({
    super.key,
    required this.task,
    required this.onTap,
    required this.onRetry,
    required this.onRemove,
  });

  final DownloadTask task;
  final VoidCallback? onTap;
  final VoidCallback onRetry;
  final VoidCallback onRemove;

  String get _statusLabel {
    return switch (task.status) {
      'queued' => 'Queued',
      'downloading' => 'Downloading ${(task.progress * 100).round()}%',
      'processing' => DownloadFormat.fromName(task.format) == DownloadFormat.mp3
          ? 'Converting to MP3…'
          : 'Combining video…',
      'complete' => 'Complete',
      'failed' => task.errorMessage ?? 'Failed',
      _ => task.status,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isFailed = task.status == 'failed';
    return AppCard(
      onTap: task.status == 'complete' ? onTap : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                DownloadFormat.fromName(task.format) == DownloadFormat.mp3
                    ? Icons.audiotrack
                    : Icons.movie_outlined,
                color: AppColors.subtext0,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  task.title,
                  style: AppTextStyles.body,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isFailed)
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Retry',
                  onPressed: onRetry,
                ),
              // Always available — including mid-download — since a task
              // can get stuck (e.g. a hung connection) with no other way
              // to clear it short of deleting the whole app database.
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: task.status == 'downloading' || task.status == 'processing'
                    ? 'Cancel'
                    : 'Remove',
                onPressed: onRemove,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _statusLabel,
            style: isFailed
                ? AppTextStyles.caption.copyWith(color: AppColors.red)
                : AppTextStyles.caption,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (task.status == 'downloading') ...[
            const SizedBox(height: AppSpacing.xs),
            LinearProgressIndicator(value: task.progress),
          ] else if (task.status == 'processing') ...[
            const SizedBox(height: AppSpacing.xs),
            const LinearProgressIndicator(),
          ],
        ],
      ),
    );
  }
}

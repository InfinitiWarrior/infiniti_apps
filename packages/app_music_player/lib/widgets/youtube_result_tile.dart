import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../services/youtube_search_service.dart';
import '../utils/duration_format.dart';

class YoutubeResultTile extends StatelessWidget {
  const YoutubeResultTile({
    super.key,
    required this.result,
    required this.onDownload,
  });

  final YoutubeSearchResult result;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onDownload,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            child: Image.network(
              result.thumbnailUrl,
              width: 80,
              height: 45,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 80,
                height: 45,
                color: AppColors.surface2,
                child: const Icon(Icons.movie_outlined, size: 20),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.title,
                  style: AppTextStyles.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    result.channelTitle,
                    if (result.duration != null)
                      formatDuration(result.duration!),
                  ].join(' · '),
                  style: AppTextStyles.bodyMuted,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.download_outlined),
            tooltip: 'Download',
            onPressed: onDownload,
          ),
        ],
      ),
    );
  }
}

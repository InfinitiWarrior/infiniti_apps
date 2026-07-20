import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../database/rss_database.dart';
import '../utils/html_utils.dart';

class ArticleTile extends StatelessWidget {
  const ArticleTile({super.key, required this.entry, required this.onTap});

  final ArticleWithFeed entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final article = entry.article;
    final preview = article.summary ?? article.content;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6, right: AppSpacing.sm),
            child: Icon(
              Icons.circle,
              size: 8,
              color: article.isRead ? Colors.transparent : AppColors.primary,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.title,
                  style: article.isRead
                      ? AppTextStyles.body
                      : AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        entry.feed.title,
                        style: AppTextStyles.caption.copyWith(color: AppColors.primary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (article.publishedAt != null) ...[
                      const Text(' · ', style: AppTextStyles.caption),
                      Text(article.publishedAt!.relative, style: AppTextStyles.caption),
                    ],
                  ],
                ),
                if (preview != null && preview.trim().isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    stripHtml(preview),
                    style: AppTextStyles.bodyMuted,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

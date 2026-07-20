import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../database/rss_database.dart';
import '../utils/html_utils.dart';

class ArticleDetailScreen extends StatelessWidget {
  const ArticleDetailScreen({super.key, required this.entry});

  final ArticleWithFeed entry;

  Future<void> _openInBrowser(BuildContext context) async {
    final link = entry.article.link;
    if (link == null) return;
    final uri = Uri.tryParse(link);
    if (uri == null) return;
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not open $link')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final article = entry.article;
    final body = article.content ?? article.summary;
    return Scaffold(
      appBar: InfinitiAppBar(
        title: entry.feed.title,
        actions: [
          if (article.link != null)
            IconButton(
              icon: const Icon(Icons.open_in_browser),
              tooltip: 'Open in browser',
              onPressed: () => _openInBrowser(context),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(article.title, style: AppTextStyles.headline),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                if (article.author != null)
                  Text(article.author!, style: AppTextStyles.caption),
                if (article.publishedAt != null)
                  Text(article.publishedAt!.formattedDateTime, style: AppTextStyles.caption),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.md),
            if (body == null || body.trim().isEmpty)
              const Text('No content available for this article.', style: AppTextStyles.bodyMuted)
            else
              SelectableText(stripHtml(body), style: AppTextStyles.body),
          ],
        ),
      ),
    );
  }
}

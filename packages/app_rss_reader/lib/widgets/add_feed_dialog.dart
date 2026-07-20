import 'package:flutter/material.dart';

class AddFeedResult {
  const AddFeedResult({required this.url, this.category});

  final String url;
  final String? category;
}

Future<AddFeedResult?> showAddFeedDialog(BuildContext context) {
  final urlController = TextEditingController();
  final categoryController = TextEditingController();

  return showDialog<AddFeedResult>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Add feed'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: urlController,
              autofocus: true,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                labelText: 'Feed URL',
                hintText: 'https://example.com/feed.xml',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(
                labelText: 'Category (optional)',
                hintText: 'News, Tech, Blogs…',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final url = urlController.text.trim();
              if (url.isEmpty) return;
              final category = categoryController.text.trim();
              Navigator.of(context).pop(
                AddFeedResult(url: url, category: category.isEmpty ? null : category),
              );
            },
            child: const Text('Add'),
          ),
        ],
      );
    },
  );
}

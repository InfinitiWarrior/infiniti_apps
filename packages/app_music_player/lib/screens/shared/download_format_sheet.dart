import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../services/download_format.dart';

Future<DownloadFormat?> showDownloadFormatSheet(BuildContext context) {
  return showModalBottomSheet<DownloadFormat>(
    context: context,
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Text('Download as', style: AppTextStyles.title),
            ),
            ListTile(
              leading: const Icon(Icons.audiotrack),
              title: const Text('MP3 (audio)'),
              subtitle: const Text('Added to your library, playable in-app'),
              onTap: () => Navigator.of(context).pop(DownloadFormat.mp3),
            ),
            ListTile(
              leading: const Icon(Icons.movie_outlined),
              title: const Text('MP4 (video)'),
              subtitle: const Text('Saved as a video file'),
              onTap: () => Navigator.of(context).pop(DownloadFormat.mp4),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      );
    },
  );
}

import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../repositories/feed_repository.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.repository});

  final FeedRepository repository;

  @override
  Widget build(BuildContext context) {
    return SettingsPage(
      sections: [
        SettingsSection(
          title: 'Articles',
          tiles: [
            ListTile(
              leading: const Icon(Icons.done_all),
              title: const Text('Mark all as read'),
              onTap: () => repository.markAllRead(),
            ),
          ],
        ),
        const SettingsSection(
          title: 'Background refresh',
          tiles: [
            ListTile(
              leading: Icon(Icons.sync),
              title: Text('Automatic background refresh'),
              subtitle: Text(
                'Feeds refresh periodically on Android/iOS via WorkManager. '
                'Not available on Linux desktop — use pull-to-refresh instead.',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

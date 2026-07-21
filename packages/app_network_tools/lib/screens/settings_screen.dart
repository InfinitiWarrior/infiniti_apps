import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../repositories/network_tools_repository.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.repository});

  final NetworkToolsRepository repository;

  Future<void> _clearHistory(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear history?'),
        content: const Text('Deletes every saved result. This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await repository.clearHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SettingsPage(
      sections: [
        SettingsSection(
          title: 'History',
          tiles: [
            ListTile(
              leading: const Icon(Icons.delete_sweep_outlined),
              title: const Text('Clear history'),
              onTap: () => _clearHistory(context),
            ),
          ],
        ),
        const SettingsSection(
          title: 'About',
          tiles: [
            ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Network Tools'),
              subtitle: Text(
                'Traceroute is implemented via repeated pings at increasing TTL, '
                'since Android has no traceroute binary to shell out to.',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

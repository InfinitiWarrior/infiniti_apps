import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../repositories/scan_repository.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.repository});

  final ScanRepository repository;

  Future<void> _clearHistory(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear history?'),
        content: const Text('Deletes every saved scan. This cannot be undone.'),
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
    if (confirmed != true) return;
    final records = await repository.watchHistory().first;
    for (final record in records) {
      await repository.delete(record.id);
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
              title: Text('NFC Toolkit'),
              subtitle: Text(
                'Android only. UID cloning is a hardware limitation and is not '
                'supported — the NFC controller has a fixed UID.',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../database/music_database.dart';
import '../repositories/music_repository.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.repository});

  final MusicRepository repository;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _rescanning = false;

  Future<void> _rescan() async {
    setState(() => _rescanning = true);
    final hasPermission = await widget.repository.hasLibraryPermission();
    if (!hasPermission) {
      final granted = await widget.repository.requestLibraryPermission();
      if (!granted) {
        setState(() => _rescanning = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Storage permission is required to scan your library.'),
            ),
          );
        }
        return;
      }
    }
    await widget.repository.rescanLibrary();
    if (mounted) setState(() => _rescanning = false);
  }

  @override
  Widget build(BuildContext context) {
    return SettingsPage(
      sections: [
        SettingsSection(
          title: 'Library',
          tiles: [
            ListTile(
              leading: _rescanning
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
              title: const Text('Rescan device library'),
              subtitle: StreamBuilder<List<Track>>(
                stream: widget.repository.watchTracks(),
                builder: (context, snapshot) {
                  final count = snapshot.data?.length ?? 0;
                  return Text('$count tracks in library');
                },
              ),
              onTap: _rescanning ? null : _rescan,
            ),
          ],
        ),
      ],
    );
  }
}

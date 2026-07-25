import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../database/music_database.dart';
import '../../repositories/music_repository.dart';

Future<void> showAddToPlaylistSheet(
  BuildContext context, {
  required MusicRepository repository,
  required Track track,
}) {
  return showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) {
      return SafeArea(
        child: StreamBuilder<List<Playlist>>(
          stream: repository.watchPlaylists(),
          builder: (context, snapshot) {
            final playlists = snapshot.data ?? const <Playlist>[];
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text('Add to playlist', style: AppTextStyles.title),
                ),
                if (playlists.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: Text(
                      'No playlists yet.',
                      style: AppTextStyles.bodyMuted,
                    ),
                  ),
                for (final playlist in playlists)
                  ListTile(
                    leading: const Icon(Icons.queue_music),
                    title: Text(playlist.name),
                    onTap: () async {
                      await repository.addTrackToPlaylist(
                        playlist.id,
                        track.id,
                      );
                      if (sheetContext.mounted) {
                        Navigator.of(sheetContext).pop();
                      }
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text('New playlist'),
                  onTap: () async {
                    final name = await promptPlaylistName(context);
                    if (name != null && name.isNotEmpty) {
                      final playlist = await repository.createPlaylist(name);
                      await repository.addTrackToPlaylist(
                        playlist.id,
                        track.id,
                      );
                    }
                    if (sheetContext.mounted) {
                      Navigator.of(sheetContext).pop();
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            );
          },
        ),
      );
    },
  );
}

/// Prompts for a new playlist name via a dialog. Shared by the "add to
/// playlist" sheet and any bulk "create playlist from selection" action.
Future<String?> promptPlaylistName(BuildContext context) {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('New playlist'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Playlist name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(controller.text.trim()),
            child: const Text('Create'),
          ),
        ],
      );
    },
  );
}

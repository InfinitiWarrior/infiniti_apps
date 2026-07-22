import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../controllers/playback_controller.dart';
import '../database/music_database.dart';
import '../repositories/music_repository.dart';
import '../widgets/playlist_tile.dart';
import 'playlist_detail_screen.dart';

class PlaylistsScreen extends StatelessWidget {
  const PlaylistsScreen({
    super.key,
    required this.repository,
    required this.playbackController,
  });

  final MusicRepository repository;
  final PlaybackController playbackController;

  Future<void> _createPlaylist(BuildContext context) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
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
    if (name != null && name.isNotEmpty) {
      await repository.createPlaylist(name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: InfinitiAppBar(
        title: 'Playlists',
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New playlist',
            onPressed: () => _createPlaylist(context),
          ),
        ],
      ),
      body: StreamBuilder<List<Playlist>>(
        stream: repository.watchPlaylists(),
        builder: (context, snapshot) {
          final playlists = snapshot.data ?? const <Playlist>[];
          if (playlists.isEmpty) {
            return const EmptyState(
              icon: Icons.queue_music_outlined,
              message: 'No playlists yet. Tap + to create one.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            itemCount: playlists.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final playlist = playlists[index];
              return PlaylistTile(
                playlist: playlist,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PlaylistDetailScreen(
                      playlist: playlist,
                      repository: repository,
                      playbackController: playbackController,
                    ),
                  ),
                ),
                onDelete: () => repository.deletePlaylist(playlist.id),
              );
            },
          );
        },
      ),
    );
  }
}

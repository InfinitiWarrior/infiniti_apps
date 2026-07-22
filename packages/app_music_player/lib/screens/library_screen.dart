import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../controllers/playback_controller.dart';
import '../database/music_database.dart';
import '../repositories/music_repository.dart';
import '../widgets/track_tile.dart';
import 'settings_screen.dart';
import 'shared/add_to_playlist_sheet.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({
    super.key,
    required this.repository,
    required this.playbackController,
  });

  final MusicRepository repository;
  final PlaybackController playbackController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: InfinitiAppBar(
        title: 'Library',
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SettingsScreen(repository: repository),
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<Track>>(
        stream: repository.watchTracks(),
        builder: (context, snapshot) {
          final tracks = snapshot.data ?? const <Track>[];
          if (tracks.isEmpty) {
            return RefreshIndicator(
              onRefresh: repository.rescanLibrary,
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: constraints.maxHeight,
                    child: const EmptyState(
                      icon: Icons.library_music_outlined,
                      message:
                          'No tracks yet. Pull down to scan your library.',
                    ),
                  ),
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: repository.rescanLibrary,
            child: ListenableBuilder(
              listenable: playbackController,
              builder: (context, _) {
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  itemCount: tracks.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final track = tracks[index];
                    return TrackTile(
                      track: track,
                      isCurrent: playbackController.currentTrack?.id ==
                          track.id,
                      onTap: () =>
                          playbackController.playTracks(tracks, startIndex: index),
                      onAddToQueue: () => playbackController.addToQueue(track),
                      onAddToPlaylist: () => showAddToPlaylistSheet(
                        context,
                        repository: repository,
                        track: track,
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

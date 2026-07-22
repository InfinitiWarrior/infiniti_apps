import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../controllers/playback_controller.dart';
import '../database/music_database.dart';
import '../repositories/music_repository.dart';
import '../widgets/track_tile.dart';

class PlaylistDetailScreen extends StatefulWidget {
  const PlaylistDetailScreen({
    super.key,
    required this.playlist,
    required this.repository,
    required this.playbackController,
  });

  final Playlist playlist;
  final MusicRepository repository;
  final PlaybackController playbackController;

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  // Cached rather than created inline in build(): this is a joined query, so
  // a fresh Stream on every rebuild would make StreamBuilder cancel and
  // resubscribe every frame.
  late final Stream<List<PlaylistTrackEntry>> _entriesStream = widget
      .repository
      .watchPlaylistTracks(widget.playlist.id);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: InfinitiAppBar(title: widget.playlist.name),
      body: StreamBuilder<List<PlaylistTrackEntry>>(
        stream: _entriesStream,
        builder: (context, snapshot) {
          final entries = snapshot.data ?? const <PlaylistTrackEntry>[];
          if (entries.isEmpty) {
            return const EmptyState(
              icon: Icons.music_off,
              message: 'No tracks in this playlist yet.',
            );
          }
          final tracks = entries.map((e) => e.track).toList();
          return ListenableBuilder(
            listenable: widget.playbackController,
            builder: (context, _) {
              return ReorderableListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                itemCount: entries.length,
                onReorderItem: (oldIndex, newIndex) {
                  final reordered = [...entries];
                  final moved = reordered.removeAt(oldIndex);
                  reordered.insert(newIndex, moved);
                  widget.repository.reorderPlaylistTracks(
                    widget.playlist.id,
                    reordered.map((e) => e.playlistTrackId).toList(),
                  );
                },
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return TrackTile(
                    key: ValueKey(entry.playlistTrackId),
                    track: entry.track,
                    isCurrent:
                        widget.playbackController.currentTrack?.id ==
                        entry.track.id,
                    onTap: () => widget.playbackController.playTracks(
                      tracks,
                      startIndex: index,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      tooltip: 'Remove from playlist',
                      onPressed: () => widget.repository
                          .removeTrackFromPlaylist(entry.playlistTrackId),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

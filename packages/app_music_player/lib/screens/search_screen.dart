import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../controllers/playback_controller.dart';
import '../database/music_database.dart';
import '../repositories/music_repository.dart';
import '../widgets/track_tile.dart';
import 'shared/add_to_playlist_sheet.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({
    super.key,
    required this.repository,
    required this.playbackController,
  });

  final MusicRepository repository;
  final PlaybackController playbackController;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: InfinitiAppBar(title: 'Search'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search your library',
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          Expanded(
            // Plain select — drift key-caches by SQL text+args, so calling
            // this inline in build() (unlike a joined/selectOnly query) is
            // safe and doesn't need to be hoisted to a field.
            child: StreamBuilder<List<Track>>(
              stream: widget.repository.watchTracks(searchQuery: _query),
              builder: (context, snapshot) {
                final tracks = snapshot.data ?? const <Track>[];
                if (_query.trim().isEmpty) {
                  return const EmptyState(
                    icon: Icons.search,
                    message: 'Search by title or artist.',
                  );
                }
                if (tracks.isEmpty) {
                  return const EmptyState(
                    icon: Icons.search_off,
                    message: 'No matching tracks.',
                  );
                }
                return ListenableBuilder(
                  listenable: widget.playbackController,
                  builder: (context, _) {
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      itemCount: tracks.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final track = tracks[index];
                        return TrackTile(
                          track: track,
                          isCurrent:
                              widget.playbackController.currentTrack?.id ==
                              track.id,
                          onTap: () => widget.playbackController.playTracks(
                            tracks,
                            startIndex: index,
                          ),
                          onAddToQueue: () =>
                              widget.playbackController.addToQueue(track),
                          onAddToPlaylist: () => showAddToPlaylistSheet(
                            context,
                            repository: widget.repository,
                            track: track,
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

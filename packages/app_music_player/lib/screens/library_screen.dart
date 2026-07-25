import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../controllers/playback_controller.dart';
import '../database/music_database.dart';
import '../repositories/music_repository.dart';
import '../widgets/track_tile.dart';
import 'settings_screen.dart';
import 'shared/add_to_playlist_sheet.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({
    super.key,
    required this.repository,
    required this.playbackController,
  });

  final MusicRepository repository;
  final PlaybackController playbackController;

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final Set<int> _selectedIds = {};

  bool get _selecting => _selectedIds.isNotEmpty;

  void _toggleSelected(int trackId) {
    setState(() {
      if (!_selectedIds.add(trackId)) {
        _selectedIds.remove(trackId);
      }
    });
  }

  void _clearSelection() => setState(_selectedIds.clear);

  Future<void> _rescan(BuildContext context) async {
    try {
      await widget.repository.rescanLibrary();
    } on LibraryPermissionDeniedException {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Storage permission is required to scan your library.'),
          ),
        );
      }
    }
  }

  /// Downloaded tracks are files this app created, so a plain confirmation
  /// dialog is enough before deleting them directly. Device-scanned tracks
  /// aren't ours to delete silently — [MusicRepository.deleteDeviceTracks]
  /// routes through Android's own scoped-storage confirmation dialog
  /// instead, so no extra dialog is shown here for those.
  Future<void> _deleteTrack(BuildContext context, Track track) async {
    if (track.source == 'download') {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete download?'),
          content: Text('This deletes "${track.title}" from your device.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      await widget.playbackController.removeTrackFromQueueEverywhere(track.id);
      await widget.repository.deleteDownloadedTrack(track);
      return;
    }
    final deleted = await widget.repository.deleteDeviceTracks([track]);
    if (deleted) {
      await widget.playbackController.removeTrackFromQueueEverywhere(track.id);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deletion cancelled.')),
      );
    }
  }

  Future<void> _deleteSelected(
    BuildContext context,
    List<Track> allTracks,
  ) async {
    final selected =
        allTracks.where((t) => _selectedIds.contains(t.id)).toList();
    final downloads = selected.where((t) => t.source == 'download').toList();
    final deviceTracks = selected.where((t) => t.source != 'download').toList();

    if (downloads.isNotEmpty) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete downloads?'),
          content: Text(
            'This deletes ${downloads.length} downloaded track'
            '${downloads.length == 1 ? '' : 's'} from your device.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
      if (confirmed == true) {
        for (final track in downloads) {
          await widget.playbackController
              .removeTrackFromQueueEverywhere(track.id);
          await widget.repository.deleteDownloadedTrack(track);
        }
      }
    }

    if (deviceTracks.isNotEmpty) {
      final deleted = await widget.repository.deleteDeviceTracks(deviceTracks);
      if (deleted) {
        for (final track in deviceTracks) {
          await widget.playbackController
              .removeTrackFromQueueEverywhere(track.id);
        }
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${deviceTracks.length} device track'
              '${deviceTracks.length == 1 ? '' : 's'} not deleted.',
            ),
          ),
        );
      }
    }

    if (mounted) _clearSelection();
  }

  Future<void> _createPlaylistFromSelected(
    BuildContext context,
    List<Track> allTracks,
  ) async {
    final selected =
        allTracks.where((t) => _selectedIds.contains(t.id)).toList();
    final name = await promptPlaylistName(context);
    if (name == null || name.isEmpty) return;
    final playlist = await widget.repository.createPlaylist(name);
    for (final track in selected) {
      await widget.repository.addTrackToPlaylist(playlist.id, track.id);
    }
    if (!mounted) return;
    _clearSelection();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Created "$name" with ${selected.length} tracks')),
      );
    }
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, List<Track> tracks) {
    if (_selecting) {
      return InfinitiAppBar(
        title: '${_selectedIds.length} selected',
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Cancel selection',
          onPressed: _clearSelection,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.playlist_add),
            tooltip: 'Create playlist from selected',
            onPressed: () => _createPlaylistFromSelected(context, tracks),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete selected',
            onPressed: () => _deleteSelected(context, tracks),
          ),
        ],
      );
    }
    return InfinitiAppBar(
      title: 'Library',
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          tooltip: 'Settings',
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SettingsScreen(repository: widget.repository),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, List<Track> tracks) {
    if (tracks.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => _rescan(context),
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: constraints.maxHeight,
              child: const EmptyState(
                icon: Icons.library_music_outlined,
                message: 'No tracks yet. Pull down to scan your library.',
              ),
            ),
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => _rescan(context),
      child: ListenableBuilder(
        listenable: widget.playbackController,
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
                isCurrent:
                    widget.playbackController.currentTrack?.id == track.id,
                selectionMode: _selecting,
                selected: _selectedIds.contains(track.id),
                onLongPress: () => _toggleSelected(track.id),
                onTap: _selecting
                    ? () => _toggleSelected(track.id)
                    : () => widget.playbackController
                        .playTracks(tracks, startIndex: index),
                onAddToQueue: () =>
                    widget.playbackController.addToQueue(track),
                onAddToPlaylist: () => showAddToPlaylistSheet(
                  context,
                  repository: widget.repository,
                  track: track,
                ),
                onDelete: () => _deleteTrack(context, track),
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Track>>(
      stream: widget.repository.watchTracks(),
      builder: (context, snapshot) {
        final tracks = snapshot.data ?? const <Track>[];
        return Scaffold(
          appBar: _buildAppBar(context, tracks),
          body: _buildBody(context, tracks),
        );
      },
    );
  }
}

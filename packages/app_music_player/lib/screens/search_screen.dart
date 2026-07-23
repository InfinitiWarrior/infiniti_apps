import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../controllers/playback_controller.dart';
import '../database/music_database.dart';
import '../repositories/download_repository.dart';
import '../repositories/music_repository.dart';
import '../services/youtube_search_service.dart';
import '../widgets/track_tile.dart';
import '../widgets/youtube_result_tile.dart';
import 'shared/add_to_playlist_sheet.dart';
import 'shared/download_format_sheet.dart';

enum _SearchMode { library, youtube }

class SearchScreen extends StatefulWidget {
  const SearchScreen({
    super.key,
    required this.repository,
    required this.playbackController,
    required this.youtubeSearchService,
    required this.downloadRepository,
  });

  final MusicRepository repository;
  final PlaybackController playbackController;
  final YoutubeSearchService youtubeSearchService;
  final DownloadRepository downloadRepository;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';
  _SearchMode _mode = _SearchMode.library;

  bool _youtubeLoading = false;
  String? _youtubeError;
  List<YoutubeSearchResult> _youtubeResults = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _runYoutubeSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _youtubeResults = []);
      return;
    }
    setState(() {
      _youtubeLoading = true;
      _youtubeError = null;
    });
    try {
      final results = await widget.youtubeSearchService.search(query);
      if (!mounted) return;
      setState(() {
        _youtubeResults = results;
        _youtubeLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _youtubeError = 'Search failed: $e';
        _youtubeLoading = false;
      });
    }
  }

  Future<void> _downloadResult(YoutubeSearchResult result) async {
    final format = await showDownloadFormatSheet(context);
    if (format == null) return;
    await widget.downloadRepository.enqueueDownload(
      videoId: result.videoId,
      title: result.title,
      channelTitle: result.channelTitle,
      duration: result.duration,
      format: format,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Downloading "${result.title}"')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: InfinitiAppBar(title: 'Search'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: SegmentedButton<_SearchMode>(
              segments: const [
                ButtonSegment(
                  value: _SearchMode.library,
                  label: Text('My Library'),
                  icon: Icon(Icons.library_music_outlined),
                ),
                ButtonSegment(
                  value: _SearchMode.youtube,
                  label: Text('YouTube'),
                  icon: Icon(Icons.ondemand_video_outlined),
                ),
              ],
              selected: {_mode},
              onSelectionChanged: (selection) =>
                  setState(() => _mode = selection.first),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: _mode == _SearchMode.library
                    ? 'Search your library'
                    : 'Search YouTube',
              ),
              onChanged: _mode == _SearchMode.library
                  ? (value) => setState(() => _query = value)
                  : null,
              onSubmitted: _mode == _SearchMode.youtube
                  ? _runYoutubeSearch
                  : null,
              textInputAction: _mode == _SearchMode.youtube
                  ? TextInputAction.search
                  : TextInputAction.none,
            ),
          ),
          Expanded(
            child: _mode == _SearchMode.library
                ? _buildLibraryResults()
                : _buildYoutubeResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildLibraryResults() {
    // Plain select — drift key-caches by SQL text+args, so calling this
    // inline in build() (unlike a joined/selectOnly query) is safe and
    // doesn't need to be hoisted to a field.
    return StreamBuilder<List<Track>>(
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
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              itemCount: tracks.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final track = tracks[index];
                return TrackTile(
                  track: track,
                  isCurrent:
                      widget.playbackController.currentTrack?.id == track.id,
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
    );
  }

  Widget _buildYoutubeResults() {
    if (_youtubeLoading) {
      return const LoadingIndicator();
    }
    if (_youtubeError != null) {
      return EmptyState(icon: Icons.error_outline, message: _youtubeError!);
    }
    if (_controller.text.trim().isEmpty) {
      return const EmptyState(
        icon: Icons.ondemand_video_outlined,
        message: 'Search YouTube to download audio or video.',
      );
    }
    if (_youtubeResults.isEmpty) {
      return const EmptyState(
        icon: Icons.search_off,
        message: 'No results.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      itemCount: _youtubeResults.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final result = _youtubeResults[index];
        return YoutubeResultTile(
          result: result,
          onDownload: () => _downloadResult(result),
        );
      },
    );
  }
}

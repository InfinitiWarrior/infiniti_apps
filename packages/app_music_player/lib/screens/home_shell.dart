import 'package:flutter/material.dart';

import '../controllers/playback_controller.dart';
import '../repositories/music_repository.dart';
import '../widgets/now_playing_bar.dart';
import 'library_screen.dart';
import 'now_playing_screen.dart';
import 'playlists_screen.dart';
import 'search_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.repository,
    required this.playbackController,
  });

  final MusicRepository repository;
  final PlaybackController playbackController;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tabIndex = 0;

  void _openNowPlaying() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NowPlayingScreen(
          controller: widget.playbackController,
          repository: widget.repository,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      LibraryScreen(
        repository: widget.repository,
        playbackController: widget.playbackController,
      ),
      SearchScreen(
        repository: widget.repository,
        playbackController: widget.playbackController,
      ),
      PlaylistsScreen(
        repository: widget.repository,
        playbackController: widget.playbackController,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _tabIndex, children: screens),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NowPlayingBar(
            controller: widget.playbackController,
            onTap: _openNowPlaying,
          ),
          NavigationBar(
            selectedIndex: _tabIndex,
            onDestinationSelected: (index) =>
                setState(() => _tabIndex = index),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.library_music_outlined),
                selectedIcon: Icon(Icons.library_music),
                label: 'Library',
              ),
              NavigationDestination(
                icon: Icon(Icons.search),
                label: 'Search',
              ),
              NavigationDestination(
                icon: Icon(Icons.queue_music_outlined),
                selectedIcon: Icon(Icons.queue_music),
                label: 'Playlists',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

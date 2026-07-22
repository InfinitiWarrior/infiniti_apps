import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter/material.dart';

import 'controllers/playback_controller.dart';
import 'database/music_database.dart';
import 'repositories/music_repository.dart';
import 'screens/home_shell.dart';
import 'services/fake_music_library_service.dart';
import 'services/fake_music_player_service.dart';
import 'services/music_library_service.dart';
import 'services/music_player_service.dart';
import 'services/playback_state_service.dart';

void main() {
  final database = MusicDatabase();

  // on_audio_query and real just_audio decoding are Android/iOS-only, same
  // as `record` elsewhere in this repo — Linux gets fakes for UI iteration.
  final isMobile = Platform.isAndroid || Platform.isIOS;
  final MusicLibraryService libraryService = isMobile
      ? PlatformMusicLibraryService()
      : FakeMusicLibraryService();
  final MusicPlayerService playerService = isMobile
      ? PlatformMusicPlayerService()
      : FakeMusicPlayerService();

  final repository = MusicRepository(database, libraryService);
  final playbackController = PlaybackController(
    repository: repository,
    playerService: playerService,
    playbackStateService: PlaybackStateService(),
  );

  runApp(
    MusicPlayerApp(
      repository: repository,
      playbackController: playbackController,
    ),
  );
}

class MusicPlayerApp extends StatelessWidget {
  const MusicPlayerApp({
    super.key,
    required this.repository,
    required this.playbackController,
  });

  final MusicRepository repository;
  final PlaybackController playbackController;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Player',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: HomeShell(
        repository: repository,
        playbackController: playbackController,
      ),
    );
  }
}

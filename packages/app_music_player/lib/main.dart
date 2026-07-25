import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'controllers/playback_controller.dart';
import 'database/music_database.dart';
import 'repositories/download_repository.dart';
import 'repositories/music_repository.dart';
import 'screens/home_shell.dart';
import 'services/fake_music_library_service.dart';
import 'services/fake_music_player_service.dart';
import 'services/fake_transcode_service.dart';
import 'services/music_library_service.dart';
import 'services/music_player_service.dart';
import 'services/playback_state_service.dart';
import 'services/transcode_service.dart';
import 'services/youtube_download_service.dart';
import 'services/youtube_search_service.dart';

Future<void> main() async {
  // Must run before anything touches a platform channel (just_audio,
  // shared_preferences, on_audio_query, ...) — without it, ServicesBinding
  // isn't attached yet and those calls fail with a null-check crash instead
  // of the plugin's own error handling ever getting a chance to run.
  WidgetsFlutterBinding.ensureInitialized();

  final database = MusicDatabase();

  // on_audio_query and real just_audio decoding are Android/iOS-only, same
  // as `record` elsewhere in this repo — Linux gets fakes for UI iteration.
  final isMobile = Platform.isAndroid || Platform.isIOS;

  // Must be called before the real AudioPlayer (inside
  // PlatformMusicPlayerService) is constructed — it's what wires playback
  // into an Android foreground service with notification/lock-screen
  // controls. No Linux implementation, hence the same isMobile guard.
  if (isMobile) {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.infinitiwarrior.musicplayer.channel.audio',
      androidNotificationChannelName: 'Music playback',
      androidNotificationOngoing: true,
    );
  }

  final MusicLibraryService libraryService = isMobile
      ? PlatformMusicLibraryService()
      : FakeMusicLibraryService();
  final MusicPlayerService playerService = isMobile
      ? PlatformMusicPlayerService()
      : FakeMusicPlayerService();

  // youtube_explode_dart is pure Dart (no platform channel), so real search
  // and raw stream download work everywhere, including Linux — always use
  // the real implementations. Only ffmpeg_kit_flutter_new (the transcode/mux
  // step) has no Linux implementation, so that alone falls back to a fake
  // there; on Linux a "download" fetches the real raw stream but the final
  // file is just copied into place rather than genuinely transcoded.
  final YoutubeSearchService youtubeSearchService = PlatformYoutubeSearchService();
  final YoutubeDownloadService youtubeDownloadService =
      PlatformYoutubeDownloadService();
  final TranscodeService transcodeService = isMobile
      ? PlatformTranscodeService()
      : FakeTranscodeService();

  final repository = MusicRepository(database, libraryService);
  final downloadRepository = DownloadRepository(
    database,
    youtubeDownloadService,
    transcodeService,
  );
  final playbackController = PlaybackController(
    repository: repository,
    playerService: playerService,
    playbackStateService: PlaybackStateService(),
  );

  runApp(
    MusicPlayerApp(
      repository: repository,
      downloadRepository: downloadRepository,
      youtubeSearchService: youtubeSearchService,
      playbackController: playbackController,
    ),
  );
}

class MusicPlayerApp extends StatelessWidget {
  const MusicPlayerApp({
    super.key,
    required this.repository,
    required this.downloadRepository,
    required this.youtubeSearchService,
    required this.playbackController,
  });

  final MusicRepository repository;
  final DownloadRepository downloadRepository;
  final YoutubeSearchService youtubeSearchService;
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
        youtubeSearchService: youtubeSearchService,
        downloadRepository: downloadRepository,
      ),
    );
  }
}

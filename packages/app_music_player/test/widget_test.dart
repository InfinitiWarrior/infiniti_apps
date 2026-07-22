import 'package:app_music_player/controllers/playback_controller.dart';
import 'package:app_music_player/database/music_database.dart';
import 'package:app_music_player/repositories/music_repository.dart';
import 'package:app_music_player/screens/home_shell.dart';
import 'package:app_music_player/services/fake_music_library_service.dart';
import 'package:app_music_player/services/fake_music_player_service.dart';
import 'package:app_music_player/services/playback_state_service.dart';
import 'package:core/core.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('shows the empty library state on first launch', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final database = MusicDatabase.forTesting(NativeDatabase.memory());
    final repository = MusicRepository(database, FakeMusicLibraryService());
    final playbackController = PlaybackController(
      repository: repository,
      playerService: FakeMusicPlayerService(),
      playbackStateService: PlaybackStateService(),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: HomeShell(
          repository: repository,
          playbackController: playbackController,
        ),
      ),
    );
    await tester.pump();

    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Library')),
      findsOneWidget,
    );
    expect(
      find.text('No tracks yet. Pull down to scan your library.'),
      findsOneWidget,
    );

    // Drift schedules an internal Timer when a stream's last listener
    // unsubscribes; explicitly closing (rather than relying on addTearDown)
    // ensures it's flushed before flutter_test's pending-timer check runs.
    await database.close();
  });
}

import 'package:app_voice_recorder/database/recorder_database.dart';
import 'package:app_voice_recorder/repositories/recordings_repository.dart';
import 'package:app_voice_recorder/screens/recorder_home_screen.dart';
import 'package:app_voice_recorder/services/audio_player_service.dart';
import 'package:app_voice_recorder/services/audio_recorder_service.dart';
import 'package:app_voice_recorder/services/recording_format.dart';
import 'package:app_voice_recorder/services/settings_service.dart';
import 'package:core/core.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeRecorderService implements AudioRecorderService {
  @override
  Future<bool> hasPermission() async => true;
  @override
  Future<void> start(String filePath, RecordingFormat format) async {}
  @override
  Future<void> pause() async {}
  @override
  Future<void> resume() async {}
  @override
  Future<String?> stop() async => null;
  @override
  Future<void> cancel() async {}
  @override
  Future<bool> isRecording() async => false;
  @override
  void dispose() {}
}

class _FakePlayerService implements AudioPlayerService {
  @override
  Stream<Duration> get positionStream => const Stream.empty();
  @override
  Stream<void> get completionStream => const Stream.empty();
  @override
  Duration? get duration => null;
  @override
  Future<void> playFile(String path) async {}
  @override
  Future<void> pause() async {}
  @override
  Future<void> stop() async {}
  @override
  void dispose() {}
}

void main() {
  testWidgets('shows the empty state and a record button on first launch', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final database = RecorderDatabase.forTesting(NativeDatabase.memory());

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: RecorderHomeScreen(
          repository: RecordingsRepository(database),
          settingsService: SettingsService(),
          recorderService: _FakeRecorderService(),
          playerService: _FakePlayerService(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('No recordings yet. Tap the mic to start.'), findsOneWidget);
    expect(find.byIcon(Icons.mic), findsOneWidget);

    // Drift schedules an internal Timer when a stream's last listener
    // unsubscribes; explicitly closing (rather than relying on addTearDown)
    // ensures it's flushed before flutter_test's pending-timer check runs.
    await database.close();
  });
}

import 'package:core/core.dart';
import 'package:flutter/material.dart';

import 'database/recorder_database.dart';
import 'repositories/recordings_repository.dart';
import 'screens/recorder_home_screen.dart';
import 'services/settings_service.dart';

void main() {
  final database = RecorderDatabase();
  runApp(
    VoiceRecorderApp(
      repository: RecordingsRepository(database),
      settingsService: SettingsService(),
    ),
  );
}

class VoiceRecorderApp extends StatelessWidget {
  const VoiceRecorderApp({
    super.key,
    required this.repository,
    required this.settingsService,
  });

  final RecordingsRepository repository;
  final SettingsService settingsService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice Recorder',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: RecorderHomeScreen(repository: repository, settingsService: settingsService),
    );
  }
}

import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../database/recorder_database.dart';
import '../repositories/recordings_repository.dart';
import '../services/audio_player_service.dart';
import '../services/audio_recorder_service.dart';
import '../services/recording_format.dart';
import '../services/settings_service.dart';
import '../widgets/recording_controls.dart';
import '../widgets/recording_tile.dart';
import '../widgets/rename_dialog.dart';
import 'settings_screen.dart';

class RecorderHomeScreen extends StatefulWidget {
  RecorderHomeScreen({
    super.key,
    required this.repository,
    required this.settingsService,
    AudioRecorderService? recorderService,
    AudioPlayerService? playerService,
  }) : recorderService = recorderService ?? PlatformAudioRecorderService(),
       playerService = playerService ?? PlatformAudioPlayerService();

  final RecordingsRepository repository;
  final SettingsService settingsService;

  /// Injectable so widget tests never touch the real `record`/`just_audio`
  /// platform channels — those hang indefinitely under `flutter_test`.
  final AudioRecorderService recorderService;
  final AudioPlayerService playerService;

  @override
  State<RecorderHomeScreen> createState() => _RecorderHomeScreenState();
}

class _RecorderHomeScreenState extends State<RecorderHomeScreen> {
  late final _recorderService = widget.recorderService;
  late final _playerService = widget.playerService;
  final _stopwatch = Stopwatch();

  Timer? _uiTimer;
  RecorderState _state = RecorderState.idle;
  Duration _elapsed = Duration.zero;
  String? _currentPath;
  RecordingFormat? _currentFormat;

  int? _playingId;
  Duration _playbackPosition = Duration.zero;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<void>? _completionSub;

  @override
  void initState() {
    super.initState();
    _positionSub = _playerService.positionStream.listen((position) {
      setState(() => _playbackPosition = position);
    });
    _completionSub = _playerService.completionStream.listen((_) {
      setState(() {
        _playingId = null;
        _playbackPosition = Duration.zero;
      });
    });
  }

  @override
  void dispose() {
    _uiTimer?.cancel();
    _positionSub?.cancel();
    _completionSub?.cancel();
    _recorderService.dispose();
    _playerService.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    final granted = await _recorderService.hasPermission();
    if (!granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission is required to record.')),
        );
      }
      return;
    }

    final format = await widget.settingsService.getFormat();
    final path = await widget.repository.newRecordingPath(format);
    await _recorderService.start(path, format);

    _currentPath = path;
    _currentFormat = format;
    _stopwatch
      ..reset()
      ..start();
    _uiTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      setState(() => _elapsed = _stopwatch.elapsed);
    });
    setState(() => _state = RecorderState.recording);
  }

  Future<void> _pauseRecording() async {
    await _recorderService.pause();
    _stopwatch.stop();
    setState(() => _state = RecorderState.paused);
  }

  Future<void> _resumeRecording() async {
    await _recorderService.resume();
    _stopwatch.start();
    setState(() => _state = RecorderState.recording);
  }

  Future<void> _stopRecording() async {
    await _recorderService.stop();
    _stopwatch.stop();
    _uiTimer?.cancel();

    final duration = _stopwatch.elapsed;
    final path = _currentPath;
    final format = _currentFormat;
    if (path != null && format != null) {
      await widget.repository.saveRecording(
        filePath: path,
        duration: duration,
        format: format,
      );
    }

    _stopwatch.reset();
    setState(() {
      _state = RecorderState.idle;
      _elapsed = Duration.zero;
      _currentPath = null;
      _currentFormat = null;
    });
  }

  Future<void> _togglePlay(Recording recording) async {
    if (_playingId == recording.id) {
      await _playerService.pause();
      setState(() => _playingId = null);
      return;
    }
    final path = await widget.repository.fullPathFor(recording);
    await _playerService.playFile(path);
    setState(() {
      _playingId = recording.id;
      _playbackPosition = Duration.zero;
    });
  }

  Future<void> _renameRecording(Recording recording) async {
    final newName = await showRenameDialog(context, recording.displayName);
    if (newName != null && newName != recording.displayName) {
      await widget.repository.rename(recording.id, newName);
    }
  }

  Future<void> _deleteRecording(Recording recording) async {
    if (_playingId == recording.id) {
      await _playerService.stop();
      setState(() => _playingId = null);
    }
    await widget.repository.delete(recording);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: InfinitiAppBar(
        title: 'Voice Recorder',
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SettingsScreen(settingsService: widget.settingsService),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: RecordingControls(
                state: _state,
                elapsed: _elapsed,
                onStart: _startRecording,
                onPause: _pauseRecording,
                onResume: _resumeRecording,
                onStop: _stopRecording,
              ),
            ),
            Expanded(
              child: StreamBuilder<List<Recording>>(
                stream: widget.repository.watchRecordings(),
                builder: (context, snapshot) {
                  final recordings = snapshot.data ?? const [];
                  if (recordings.isEmpty) {
                    return const EmptyState(
                      icon: Icons.mic_none,
                      message: 'No recordings yet. Tap the mic to start.',
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    itemCount: recordings.length,
                    itemBuilder: (context, index) {
                      final recording = recordings[index];
                      return RecordingTile(
                        recording: recording,
                        isPlaying: _playingId == recording.id,
                        playbackPosition: _playingId == recording.id
                            ? _playbackPosition
                            : Duration.zero,
                        onPlayToggle: () => _togglePlay(recording),
                        onRename: () => _renameRecording(recording),
                        onDelete: () => _deleteRecording(recording),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

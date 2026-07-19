import 'package:just_audio/just_audio.dart';

/// Playback control surface. Abstracted so widget tests can supply a fake
/// instead of touching the real `just_audio` platform channel.
abstract class AudioPlayerService {
  Stream<Duration> get positionStream;

  /// Fires when playback reaches the end of the file.
  Stream<void> get completionStream;

  Duration? get duration;

  Future<void> playFile(String path);
  Future<void> pause();
  Future<void> stop();
  void dispose();
}

class PlatformAudioPlayerService implements AudioPlayerService {
  PlatformAudioPlayerService() : _player = AudioPlayer();

  final AudioPlayer _player;

  @override
  Stream<Duration> get positionStream => _player.positionStream;

  @override
  Stream<void> get completionStream => _player.playerStateStream
      .where((state) => state.processingState == ProcessingState.completed)
      .map((_) {});

  @override
  Duration? get duration => _player.duration;

  @override
  Future<void> playFile(String path) async {
    await _player.setFilePath(path);
    await _player.play();
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();

  @override
  void dispose() => _player.dispose();
}

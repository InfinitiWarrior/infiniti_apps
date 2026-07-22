import 'dart:async';

import 'music_player_service.dart';
import 'repeat_mode.dart';

/// No-op stand-in for [MusicPlayerService] used on Linux, where real audio
/// decoding isn't the point of desktop iteration — this just lets the queue
/// UI reflect a "current track" without touching a platform channel.
class FakeMusicPlayerService implements MusicPlayerService {
  final _currentIndexController = StreamController<int?>.broadcast();
  final _playingController = StreamController<bool>.broadcast();
  int? _currentIndex;
  bool _playing = false;

  @override
  Stream<Duration> get positionStream => const Stream.empty();

  @override
  Stream<int?> get currentIndexStream => _currentIndexController.stream;

  @override
  Stream<bool> get playingStream => _playingController.stream;

  @override
  Stream<void> get completionStream => const Stream.empty();

  @override
  Duration? get duration => null;

  @override
  Future<void> setQueue(
    List<String> filePaths, {
    int initialIndex = 0,
    Duration? initialPosition,
  }) async {
    _currentIndex = filePaths.isEmpty ? null : initialIndex;
    _currentIndexController.add(_currentIndex);
  }

  @override
  Future<void> play() async {
    _playing = true;
    _playingController.add(_playing);
  }

  @override
  Future<void> pause() async {
    _playing = false;
    _playingController.add(_playing);
  }

  @override
  Future<void> seek(Duration position) async {}

  @override
  Future<void> skipToIndex(int index) async {
    _currentIndex = index;
    _currentIndexController.add(_currentIndex);
  }

  @override
  Future<void> skipNext() async {
    if (_currentIndex != null) {
      _currentIndex = _currentIndex! + 1;
      _currentIndexController.add(_currentIndex);
    }
  }

  @override
  Future<void> skipPrevious() async {
    if (_currentIndex != null && _currentIndex! > 0) {
      _currentIndex = _currentIndex! - 1;
      _currentIndexController.add(_currentIndex);
    }
  }

  @override
  Future<void> setRepeatMode(PlayerRepeatMode mode) async {}

  @override
  Future<void> setShuffleEnabled(bool enabled) async {}

  @override
  void dispose() {
    _currentIndexController.close();
    _playingController.close();
  }
}

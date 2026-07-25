import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import '../database/music_database.dart';
import 'repeat_mode.dart';

/// Queue-aware playback control surface. Abstracted so widget tests can
/// supply a fake instead of touching the real `just_audio` platform channel.
abstract class MusicPlayerService {
  Stream<Duration> get positionStream;
  Stream<int?> get currentIndexStream;
  Stream<bool> get playingStream;

  /// Fires when the queue reaches the end of its last track.
  Stream<void> get completionStream;

  Duration? get duration;

  /// Takes full [Track]s (not just file paths) so the platform implementation
  /// can attach title/artist/duration to each `AudioSource` as a `MediaItem`
  /// — that's what the background-playback notification displays.
  Future<void> setQueue(
    List<Track> tracks, {
    int initialIndex = 0,
    Duration? initialPosition,
  });
  Future<void> play();
  Future<void> pause();
  Future<void> seek(Duration position);
  Future<void> skipToIndex(int index);
  Future<void> skipNext();
  Future<void> skipPrevious();

  /// Delegates to the player's own loop handling (off/one/all) rather than
  /// hand-rolling repeat via completion events.
  Future<void> setRepeatMode(PlayerRepeatMode mode);
  Future<void> setShuffleEnabled(bool enabled);
  void dispose();
}

class PlatformMusicPlayerService implements MusicPlayerService {
  PlatformMusicPlayerService() : _player = AudioPlayer();

  final AudioPlayer _player;

  AudioSource _toAudioSource(Track track) => AudioSource.uri(
    Uri.file(track.filePath),
    tag: MediaItem(
      id: track.id.toString(),
      title: track.title,
      artist: track.artist,
      album: track.album,
      duration: Duration(milliseconds: track.durationMs),
    ),
  );

  @override
  Stream<Duration> get positionStream => _player.positionStream;

  @override
  Stream<int?> get currentIndexStream => _player.currentIndexStream;

  @override
  Stream<bool> get playingStream => _player.playingStream;

  @override
  Stream<void> get completionStream => _player.processingStateStream
      .where((state) => state == ProcessingState.completed)
      .map((_) {});

  @override
  Duration? get duration => _player.duration;

  @override
  Future<void> setQueue(
    List<Track> tracks, {
    int initialIndex = 0,
    Duration? initialPosition,
  }) {
    return _player
        .setAudioSources(
          tracks.map(_toAudioSource).toList(),
          initialIndex: tracks.isEmpty ? null : initialIndex,
          initialPosition: initialPosition,
        )
        .then((_) => null);
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToIndex(int index) => _player.seek(Duration.zero, index: index);

  @override
  Future<void> skipNext() => _player.seekToNext();

  @override
  Future<void> skipPrevious() => _player.seekToPrevious();

  @override
  Future<void> setRepeatMode(PlayerRepeatMode mode) {
    return _player.setLoopMode(switch (mode) {
      PlayerRepeatMode.off => LoopMode.off,
      PlayerRepeatMode.one => LoopMode.one,
      PlayerRepeatMode.all => LoopMode.all,
    });
  }

  @override
  Future<void> setShuffleEnabled(bool enabled) =>
      _player.setShuffleModeEnabled(enabled);

  @override
  void dispose() => _player.dispose();
}

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../database/music_database.dart';
import '../repositories/music_repository.dart';
import '../services/music_player_service.dart';
import '../services/playback_state_service.dart';
import '../services/repeat_mode.dart';

/// Orchestrates queue playback: keeps the persisted queue (drift, via
/// [MusicRepository]) and the live player ([MusicPlayerService]) in sync, and
/// exposes current-track/position/shuffle/repeat state to the UI. Business
/// logic lives here rather than in widget `build()` methods.
class PlaybackController extends ChangeNotifier {
  PlaybackController({
    required this.repository,
    required this.playerService,
    required this.playbackStateService,
  }) {
    _init();
  }

  final MusicRepository repository;
  final MusicPlayerService playerService;
  final PlaybackStateService playbackStateService;

  List<Track> _queueTracks = [];
  int? _currentIndex;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  PlayerRepeatMode _repeatMode = PlayerRepeatMode.off;
  bool _shuffleEnabled = false;

  StreamSubscription<List<QueueEntry>>? _queueSub;
  StreamSubscription<int?>? _indexSub;
  StreamSubscription<bool>? _playingSub;
  StreamSubscription<Duration>? _positionSub;

  List<Track> get queueTracks => _queueTracks;

  Track? get currentTrack =>
      _currentIndex != null && _currentIndex! < _queueTracks.length
      ? _queueTracks[_currentIndex!]
      : null;

  int? get currentIndex => _currentIndex;
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration? get duration => playerService.duration;
  PlayerRepeatMode get repeatMode => _repeatMode;
  bool get shuffleEnabled => _shuffleEnabled;

  Future<void> _init() async {
    _repeatMode = await playbackStateService.getRepeatMode();
    _shuffleEnabled = await playbackStateService.getShuffleEnabled();
    await playerService.setRepeatMode(_repeatMode);
    await playerService.setShuffleEnabled(_shuffleEnabled);

    _queueSub = repository.watchQueue().listen((entries) {
      _queueTracks = entries.map((e) => e.track).toList();
      notifyListeners();
    });
    _indexSub = playerService.currentIndexStream.listen((index) {
      _currentIndex = index;
      notifyListeners();
    });
    _playingSub = playerService.playingStream.listen((playing) {
      _isPlaying = playing;
      notifyListeners();
    });
    _positionSub = playerService.positionStream.listen((position) {
      _position = position;
      notifyListeners();
    });
  }

  /// Replaces the queue with [tracks] (persisted + loaded into the player)
  /// and starts playback at [startIndex].
  Future<void> playTracks(List<Track> tracks, {int startIndex = 0}) async {
    await repository.setQueue(tracks.map((t) => t.id).toList());
    await playerService.setQueue(
      tracks,
      initialIndex: startIndex,
    );
    await playerService.play();
  }

  /// Appends [track] to both the persisted queue and the live player,
  /// preserving current playback position.
  Future<void> addToQueue(Track track) async {
    await repository.addToQueue(track.id);
    final tracks = [..._queueTracks, track];
    await playerService.setQueue(
      tracks,
      initialIndex: _currentIndex ?? 0,
      initialPosition: _position,
    );
  }

  /// Removes the queue entry at [index] from both the persisted queue and
  /// the live player, preserving current playback position where possible.
  Future<void> removeFromQueueAt(int index, int queueItemId) async {
    await repository.removeFromQueue(queueItemId);
    final tracks = [..._queueTracks]..removeAt(index);
    var newIndex = _currentIndex ?? 0;
    if (index < newIndex) {
      newIndex -= 1;
    } else if (index == newIndex) {
      newIndex = newIndex.clamp(0, tracks.isEmpty ? 0 : tracks.length - 1);
    }
    await playerService.setQueue(
      tracks,
      initialIndex: tracks.isEmpty ? 0 : newIndex,
      initialPosition: index == (_currentIndex ?? 0) ? null : _position,
    );
  }

  /// Reorders the queue to [queueItemIdsInOrder]/[tracksInOrder] (must be the
  /// same order), preserving current playback position.
  Future<void> reorderQueue(
    List<int> queueItemIdsInOrder,
    List<Track> tracksInOrder,
  ) async {
    final playingTrackId = currentTrack?.id;
    await repository.reorderQueue(queueItemIdsInOrder);
    final newIndex = playingTrackId == null
        ? 0
        : tracksInOrder.indexWhere((t) => t.id == playingTrackId).clamp(
            0,
            tracksInOrder.isEmpty ? 0 : tracksInOrder.length - 1,
          );
    await playerService.setQueue(
      tracksInOrder,
      initialIndex: newIndex,
      initialPosition: _position,
    );
  }

  /// Removes [trackId] from the queue wherever it appears, correctly
  /// resyncing the live player (stopping/skipping if it was the current
  /// track) via the same path [removeFromQueueAt] already uses. No-op if the
  /// track isn't queued. Call before deleting a track so a deleted file is
  /// never left loaded in the player.
  Future<void> removeTrackFromQueueEverywhere(int trackId) async {
    final index = _queueTracks.indexWhere((t) => t.id == trackId);
    if (index == -1) return;
    final entries = await repository.watchQueue().first;
    final entry = entries.firstWhere((e) => e.track.id == trackId);
    await removeFromQueueAt(index, entry.queueItemId);
  }

  /// Stops playback and clears the queue entirely — "closes" whatever's
  /// currently playing so the mini-player disappears.
  Future<void> stop() async {
    await repository.clearQueue();
    await playerService.setQueue(const []);
  }

  Future<void> togglePlayPause() {
    return _isPlaying ? playerService.pause() : playerService.play();
  }

  Future<void> seek(Duration position) => playerService.seek(position);
  Future<void> skipNext() => playerService.skipNext();
  Future<void> skipPrevious() => playerService.skipPrevious();
  Future<void> skipToIndex(int index) => playerService.skipToIndex(index);

  Future<void> setRepeatMode(PlayerRepeatMode mode) async {
    _repeatMode = mode;
    await playbackStateService.setRepeatMode(mode);
    await playerService.setRepeatMode(mode);
    notifyListeners();
  }

  Future<void> setShuffleEnabled(bool enabled) async {
    _shuffleEnabled = enabled;
    await playbackStateService.setShuffleEnabled(enabled);
    await playerService.setShuffleEnabled(enabled);
    notifyListeners();
  }

  @override
  void dispose() {
    _queueSub?.cancel();
    _indexSub?.cancel();
    _playingSub?.cancel();
    _positionSub?.cancel();
    playerService.dispose();
    super.dispose();
  }
}

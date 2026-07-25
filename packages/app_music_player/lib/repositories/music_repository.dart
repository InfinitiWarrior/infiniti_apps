import 'dart:io';

import 'package:drift/drift.dart';

import '../database/music_database.dart';
import '../services/device_track.dart';
import '../services/music_library_service.dart';

/// Thrown by [MusicRepository.rescanLibrary] when the device media-library
/// permission is missing and the user declines the request. Calling
/// `on_audio_query`'s `querySongs` without that permission granted doesn't
/// just fail cleanly — on this plugin version it double-replies on the
/// method channel and crashes the whole app natively, so callers must never
/// reach [MusicLibraryService.queryTracks] without checking first.
class LibraryPermissionDeniedException implements Exception {
  @override
  String toString() =>
      'LibraryPermissionDeniedException: media library permission denied';
}

/// Combines the local drift library with the device media-store scan, so
/// callers never have to juggle [DeviceTrack]s and drift rows separately.
class MusicRepository {
  MusicRepository(this._database, this._libraryService);

  final MusicDatabase _database;
  final MusicLibraryService _libraryService;

  Stream<List<Track>> watchTracks({String? searchQuery}) =>
      _database.watchTracks(searchQuery: searchQuery);

  Future<Track?> getTrack(int id) => _database.getTrack(id);

  Stream<List<Playlist>> watchPlaylists() => _database.watchPlaylists();

  Stream<List<PlaylistTrackEntry>> watchPlaylistTracks(int playlistId) =>
      _database.watchPlaylistTracks(playlistId);

  Stream<List<QueueEntry>> watchQueue() => _database.watchQueue();

  /// Scans the device media store and merges results into the local library.
  ///
  /// Throws [LibraryPermissionDeniedException] instead of ever calling into
  /// the platform query without permission — see that class's doc comment
  /// for why.
  Future<void> rescanLibrary() async {
    var granted = await _libraryService.hasPermission();
    if (!granted) {
      granted = await _libraryService.requestPermission();
    }
    if (!granted) {
      throw LibraryPermissionDeniedException();
    }
    final deviceTracks = await _libraryService.queryTracks();
    final companions = deviceTracks
        .map(
          (track) => TracksCompanion.insert(
            source: 'device',
            deviceAudioId: Value(track.deviceAudioId),
            filePath: track.filePath,
            title: track.title,
            artist: Value(track.artist),
            album: Value(track.album),
            durationMs: track.durationMs,
          ),
        )
        .toList();
    await _database.syncDeviceTracks(companions);
  }

  /// Deletes a downloaded track's row and its file on disk. Device-scanned
  /// tracks aren't deletable this way — they're a view into the real device
  /// media store, not something this app owns.
  Future<void> deleteDownloadedTrack(Track track) async {
    assert(track.source == 'download');
    await _database.deleteTrack(track.id);
    final file = File(track.filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Deletes device-scanned tracks. Unlike [deleteDownloadedTrack], these
  /// are files the app doesn't own, so the OS's own scoped-storage
  /// confirmation UI decides (see [MusicLibraryService.deleteDeviceAudio])
  /// — either every track in [tracks] is deleted, or the whole batch is
  /// cancelled and nothing is. Local rows are only removed on confirmation.
  Future<bool> deleteDeviceTracks(List<Track> tracks) async {
    final ids = [
      for (final track in tracks)
        if (track.deviceAudioId != null) track.deviceAudioId!,
    ];
    if (ids.isEmpty) return false;
    final confirmed = await _libraryService.deleteDeviceAudio(ids);
    if (confirmed) {
      for (final track in tracks) {
        await _database.deleteTrack(track.id);
      }
    }
    return confirmed;
  }

  Future<Playlist> createPlaylist(String name) =>
      _database.createPlaylist(name);

  Future<void> deletePlaylist(int playlistId) =>
      _database.deletePlaylist(playlistId);

  Future<void> addTrackToPlaylist(int playlistId, int trackId) =>
      _database.addTrackToPlaylist(playlistId, trackId);

  Future<void> removeTrackFromPlaylist(int playlistTrackId) =>
      _database.removeTrackFromPlaylist(playlistTrackId);

  Future<void> reorderPlaylistTracks(
    int playlistId,
    List<int> playlistTrackIdsInOrder,
  ) => _database.reorderPlaylistTracks(playlistId, playlistTrackIdsInOrder);

  Future<void> setQueue(List<int> trackIds) => _database.setQueue(trackIds);

  Future<void> addToQueue(int trackId) => _database.addToQueue(trackId);

  Future<void> removeFromQueue(int queueItemId) =>
      _database.removeFromQueue(queueItemId);

  Future<void> reorderQueue(List<int> queueItemIdsInOrder) =>
      _database.reorderQueue(queueItemIdsInOrder);

  Future<void> clearQueue() => _database.clearQueue();
}

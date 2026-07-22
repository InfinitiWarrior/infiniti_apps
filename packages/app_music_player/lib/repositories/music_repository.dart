import 'package:drift/drift.dart';

import '../database/music_database.dart';
import '../services/device_track.dart';
import '../services/music_library_service.dart';

/// Combines the local drift library with the device media-store scan, so
/// callers never have to juggle [DeviceTrack]s and drift rows separately.
class MusicRepository {
  MusicRepository(this._database, this._libraryService);

  final MusicDatabase _database;
  final MusicLibraryService _libraryService;

  Stream<List<Track>> watchTracks({String? searchQuery}) =>
      _database.watchTracks(searchQuery: searchQuery);

  Stream<List<Playlist>> watchPlaylists() => _database.watchPlaylists();

  Stream<List<PlaylistTrackEntry>> watchPlaylistTracks(int playlistId) =>
      _database.watchPlaylistTracks(playlistId);

  Stream<List<QueueEntry>> watchQueue() => _database.watchQueue();

  Future<bool> hasLibraryPermission() => _libraryService.hasPermission();

  Future<bool> requestLibraryPermission() =>
      _libraryService.requestPermission();

  /// Scans the device media store and merges results into the local library.
  Future<void> rescanLibrary() async {
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

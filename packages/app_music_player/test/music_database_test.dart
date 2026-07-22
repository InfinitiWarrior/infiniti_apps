import 'package:app_music_player/database/music_database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MusicDatabase database;

  setUp(() {
    database = MusicDatabase.forTesting(NativeDatabase.memory());
  });

  Future<Track> insertTrack(
    String title, {
    int? deviceAudioId,
    String source = 'device',
  }) async {
    return database.insertDownloadedTrack(
      TracksCompanion.insert(
        source: source,
        deviceAudioId: Value(deviceAudioId),
        filePath: '/music/$title.mp3',
        title: title,
        durationMs: 180000,
      ),
    );
  }

  test('syncDeviceTracks inserts new tracks and updates existing ones', () async {
    await database.syncDeviceTracks([
      TracksCompanion.insert(
        source: 'device',
        deviceAudioId: const Value(1),
        filePath: '/music/a.mp3',
        title: 'Track A',
        durationMs: 100000,
      ),
    ]);
    var tracks = await database.watchTracks().first;
    expect(tracks, hasLength(1));
    expect(tracks.single.title, 'Track A');

    // Re-syncing the same deviceAudioId updates metadata instead of
    // inserting a duplicate row.
    await database.syncDeviceTracks([
      TracksCompanion.insert(
        source: 'device',
        deviceAudioId: const Value(1),
        filePath: '/music/a.mp3',
        title: 'Track A Renamed',
        durationMs: 100000,
      ),
    ]);
    tracks = await database.watchTracks().first;
    expect(tracks, hasLength(1));
    expect(tracks.single.title, 'Track A Renamed');

    await database.close();
  });

  test('watchTracks filters by search query across title and artist', () async {
    await database.insertDownloadedTrack(
      TracksCompanion.insert(
        source: 'download',
        filePath: '/music/b.mp3',
        title: 'Blue Skies',
        artist: const Value('Some Artist'),
        durationMs: 100000,
      ),
    );
    await database.insertDownloadedTrack(
      TracksCompanion.insert(
        source: 'download',
        filePath: '/music/c.mp3',
        title: 'Green Fields',
        artist: const Value('Another Blue'),
        durationMs: 100000,
      ),
    );

    final byTitle = await database.watchTracks(searchQuery: 'blue skies').first;
    expect(byTitle, hasLength(1));

    final byArtist = await database.watchTracks(searchQuery: 'blue').first;
    expect(byArtist, hasLength(2));

    await database.close();
  });

  test('playlist tracks join, reorder, and cascade on playlist delete', () async {
    final trackA = await insertTrack('A');
    final trackB = await insertTrack('B');
    final playlist = await database.createPlaylist('Favorites');

    await database.addTrackToPlaylist(playlist.id, trackA.id);
    await database.addTrackToPlaylist(playlist.id, trackB.id);

    var entries = await database.watchPlaylistTracks(playlist.id).first;
    expect(entries.map((e) => e.track.title), ['A', 'B']);

    await database.reorderPlaylistTracks(playlist.id, [
      entries[1].playlistTrackId,
      entries[0].playlistTrackId,
    ]);
    entries = await database.watchPlaylistTracks(playlist.id).first;
    expect(entries.map((e) => e.track.title), ['B', 'A']);

    await database.deletePlaylist(playlist.id);
    entries = await database.watchPlaylistTracks(playlist.id).first;
    expect(entries, isEmpty);

    // Deleting the playlist must not touch the underlying tracks.
    final remainingTracks = await database.watchTracks().first;
    expect(remainingTracks, hasLength(2));

    await database.close();
  });

  test('queue reorders and cascades when a track is deleted', () async {
    final trackA = await insertTrack('A');
    final trackB = await insertTrack('B');

    await database.setQueue([trackA.id, trackB.id]);
    var queue = await database.watchQueue().first;
    expect(queue.map((e) => e.track.title), ['A', 'B']);

    await database.reorderQueue([
      queue[1].queueItemId,
      queue[0].queueItemId,
    ]);
    queue = await database.watchQueue().first;
    expect(queue.map((e) => e.track.title), ['B', 'A']);

    await (database.delete(
      database.tracks,
    )..where((t) => t.id.equals(trackA.id))).go();
    queue = await database.watchQueue().first;
    expect(queue, hasLength(1));
    expect(queue.single.track.title, 'B');

    await database.close();
  });
}

import 'package:core/core.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;

part 'music_database.g.dart';

class Tracks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get source => text()(); // 'device' | 'download'
  IntColumn get deviceAudioId => integer().nullable()();
  TextColumn get filePath => text()();
  TextColumn get title => text()();
  TextColumn get artist => text().nullable()();
  TextColumn get album => text().nullable()();
  IntColumn get durationMs => integer()();
  TextColumn get youtubeVideoId => text().nullable()();
  DateTimeColumn get addedAt => dateTime().withDefault(currentDateAndTime)();
}

class Playlists extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class PlaylistTracks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get playlistId =>
      integer().references(Playlists, #id, onDelete: KeyAction.cascade)();
  IntColumn get trackId =>
      integer().references(Tracks, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();
  DateTimeColumn get addedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {playlistId, trackId},
  ];
}

class QueueItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get trackId =>
      integer().references(Tracks, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();
}

class DownloadTasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get youtubeVideoId => text()();
  TextColumn get title => text()();
  TextColumn get channelTitle => text().nullable()();
  IntColumn get durationMs => integer().nullable()();
  TextColumn get format => text()(); // 'mp3' | 'mp4'
  TextColumn get status =>
      text()(); // 'queued' | 'downloading' | 'processing' | 'complete' | 'failed'
  RealColumn get progress => real().withDefault(const Constant(0.0))();
  TextColumn get errorMessage => text().nullable()();
  TextColumn get filePath => text().nullable()();
  IntColumn get trackId =>
      integer().nullable().references(Tracks, #id, onDelete: KeyAction.setNull)();
  DateTimeColumn get requestedAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get completedAt => dateTime().nullable()();
}

class PlaylistTrackEntry {
  PlaylistTrackEntry({required this.playlistTrackId, required this.track});

  final int playlistTrackId;
  final Track track;
}

class QueueEntry {
  QueueEntry({required this.queueItemId, required this.track});

  final int queueItemId;
  final Track track;
}

@DriftDatabase(
  tables: [Tracks, Playlists, PlaylistTracks, QueueItems, DownloadTasks],
)
class MusicDatabase extends _$MusicDatabase {
  MusicDatabase() : super(openAppConnection('music_player.sqlite'));

  @visibleForTesting
  MusicDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  // SQLite disables foreign key enforcement by default; without this, the
  // `onDelete: KeyAction.cascade` on PlaylistTracks/QueueItems is a no-op and
  // deleting a Track/Playlist leaves orphaned rows behind.
  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Stream<List<Track>> watchTracks({String? searchQuery}) {
    final query = select(tracks);
    final trimmed = searchQuery?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      final pattern = '%${trimmed.toLowerCase()}%';
      query.where(
        (t) =>
            t.title.lower().like(pattern) | t.artist.lower().like(pattern),
      );
    }
    query.orderBy([(t) => OrderingTerm.asc(t.title)]);
    return query.watch();
  }

  /// Inserts device-scanned tracks that don't already exist (matched by
  /// `deviceAudioId`) and refreshes metadata for ones that do.
  Future<void> syncDeviceTracks(List<TracksCompanion> incoming) async {
    final existing = await (select(
      tracks,
    )..where((t) => t.source.equals('device'))).get();
    final existingByDeviceId = {
      for (final track in existing) track.deviceAudioId: track,
    };
    await batch((b) {
      for (final companion in incoming) {
        final deviceAudioId = companion.deviceAudioId.value;
        final existingTrack = existingByDeviceId[deviceAudioId];
        if (existingTrack == null) {
          b.insert(tracks, companion);
        } else {
          b.update(
            tracks,
            companion,
            where: (t) => t.id.equals(existingTrack.id),
          );
        }
      }
    });
  }

  Future<Track> insertDownloadedTrack(TracksCompanion companion) async {
    final id = await into(tracks).insert(companion);
    return (select(tracks)..where((t) => t.id.equals(id))).getSingle();
  }

  Future<Track?> getTrack(int id) {
    return (select(tracks)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Cascades to PlaylistTracks/QueueItems (FK `onDelete: cascade`) and nulls
  /// out any DownloadTasks.trackId referencing it (FK `onDelete: setNull`).
  Future<void> deleteTrack(int id) {
    return (delete(tracks)..where((t) => t.id.equals(id))).go();
  }

  Stream<List<Playlist>> watchPlaylists() {
    return (select(
      playlists,
    )..orderBy([(t) => OrderingTerm.asc(t.name)])).watch();
  }

  Future<Playlist> createPlaylist(String name) async {
    final id = await into(
      playlists,
    ).insert(PlaylistsCompanion.insert(name: name));
    return (select(playlists)..where((t) => t.id.equals(id))).getSingle();
  }

  Future<void> deletePlaylist(int playlistId) {
    return (delete(playlists)..where((t) => t.id.equals(playlistId))).go();
  }

  Stream<List<PlaylistTrackEntry>> watchPlaylistTracks(int playlistId) {
    final query = select(playlistTracks).join([
      innerJoin(tracks, tracks.id.equalsExp(playlistTracks.trackId)),
    ])..where(playlistTracks.playlistId.equals(playlistId));
    query.orderBy([OrderingTerm.asc(playlistTracks.position)]);
    return query.watch().map(
      (rows) => rows
          .map(
            (row) => PlaylistTrackEntry(
              playlistTrackId: row.readTable(playlistTracks).id,
              track: row.readTable(tracks),
            ),
          )
          .toList(),
    );
  }

  Future<void> addTrackToPlaylist(int playlistId, int trackId) async {
    final count =
        await (selectOnly(playlistTracks)
              ..addColumns([playlistTracks.id.count()])
              ..where(playlistTracks.playlistId.equals(playlistId)))
            .map((row) => row.read(playlistTracks.id.count()) ?? 0)
            .getSingle();
    await into(playlistTracks).insert(
      PlaylistTracksCompanion.insert(
        playlistId: playlistId,
        trackId: trackId,
        position: count,
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }

  Future<void> removeTrackFromPlaylist(int playlistTrackId) {
    return (delete(
      playlistTracks,
    )..where((t) => t.id.equals(playlistTrackId))).go();
  }

  /// Replaces the ordering of a playlist's tracks wholesale — simpler and
  /// less error-prone than incremental position-swap math for drag-reorder.
  Future<void> reorderPlaylistTracks(
    int playlistId,
    List<int> playlistTrackIdsInOrder,
  ) async {
    await batch((b) {
      for (var i = 0; i < playlistTrackIdsInOrder.length; i++) {
        b.update(
          playlistTracks,
          PlaylistTracksCompanion(position: Value(i)),
          where: (t) => t.id.equals(playlistTrackIdsInOrder[i]),
        );
      }
    });
  }

  Stream<List<QueueEntry>> watchQueue() {
    final query = select(queueItems).join([
      innerJoin(tracks, tracks.id.equalsExp(queueItems.trackId)),
    ]);
    query.orderBy([OrderingTerm.asc(queueItems.position)]);
    return query.watch().map(
      (rows) => rows
          .map(
            (row) => QueueEntry(
              queueItemId: row.readTable(queueItems).id,
              track: row.readTable(tracks),
            ),
          )
          .toList(),
    );
  }

  /// Replaces the entire queue with the given track order.
  Future<void> setQueue(List<int> trackIds) async {
    await batch((b) {
      b.deleteWhere(queueItems, (t) => const Constant(true));
      for (var i = 0; i < trackIds.length; i++) {
        b.insert(
          queueItems,
          QueueItemsCompanion.insert(trackId: trackIds[i], position: i),
        );
      }
    });
  }

  Future<void> addToQueue(int trackId) async {
    final count =
        await (selectOnly(queueItems)
              ..addColumns([queueItems.id.count()]))
            .map((row) => row.read(queueItems.id.count()) ?? 0)
            .getSingle();
    await into(queueItems).insert(
      QueueItemsCompanion.insert(trackId: trackId, position: count),
    );
  }

  Future<void> removeFromQueue(int queueItemId) {
    return (delete(queueItems)..where((t) => t.id.equals(queueItemId))).go();
  }

  Future<void> reorderQueue(List<int> queueItemIdsInOrder) async {
    await batch((b) {
      for (var i = 0; i < queueItemIdsInOrder.length; i++) {
        b.update(
          queueItems,
          QueueItemsCompanion(position: Value(i)),
          where: (t) => t.id.equals(queueItemIdsInOrder[i]),
        );
      }
    });
  }

  Future<void> clearQueue() {
    return delete(queueItems).go();
  }

  Stream<List<DownloadTask>> watchDownloadTasks() {
    return (select(downloadTasks)
          ..orderBy([(t) => OrderingTerm.desc(t.requestedAt)]))
        .watch();
  }

  Future<DownloadTask> insertDownloadTask(DownloadTasksCompanion companion) async {
    final id = await into(downloadTasks).insert(companion);
    return (select(
      downloadTasks,
    )..where((t) => t.id.equals(id))).getSingle();
  }

  Future<DownloadTask> getDownloadTask(int id) {
    return (select(downloadTasks)..where((t) => t.id.equals(id))).getSingle();
  }

  Future<void> setDownloadTaskStatus(
    int id, {
    required String status,
    double? progress,
  }) {
    return (update(downloadTasks)..where((t) => t.id.equals(id))).write(
      DownloadTasksCompanion(
        status: Value(status),
        progress: progress == null ? const Value.absent() : Value(progress),
      ),
    );
  }

  Future<void> setDownloadTaskProgress(int id, double progress) {
    return (update(downloadTasks)..where((t) => t.id.equals(id))).write(
      DownloadTasksCompanion(progress: Value(progress)),
    );
  }

  Future<void> completeDownloadTask(
    int id, {
    required String filePath,
    int? trackId,
  }) {
    return (update(downloadTasks)..where((t) => t.id.equals(id))).write(
      DownloadTasksCompanion(
        status: const Value('complete'),
        progress: const Value(1.0),
        filePath: Value(filePath),
        trackId: trackId == null ? const Value.absent() : Value(trackId),
        completedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> failDownloadTask(int id, String errorMessage) {
    return (update(downloadTasks)..where((t) => t.id.equals(id))).write(
      DownloadTasksCompanion(
        status: const Value('failed'),
        errorMessage: Value(errorMessage),
      ),
    );
  }

  Future<void> removeDownloadTask(int id) {
    return (delete(downloadTasks)..where((t) => t.id.equals(id))).go();
  }
}

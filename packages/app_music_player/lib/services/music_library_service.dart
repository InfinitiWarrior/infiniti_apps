import 'package:on_audio_query/on_audio_query.dart';

import 'device_track.dart';

/// Device media-library access. Abstracted so widget tests and Linux dev
/// iteration never touch the real `on_audio_query` platform channel, which
/// (like `record`) has no Linux implementation.
abstract class MusicLibraryService {
  Future<bool> hasPermission();
  Future<bool> requestPermission();
  Future<List<DeviceTrack>> queryTracks();
}

class PlatformMusicLibraryService implements MusicLibraryService {
  PlatformMusicLibraryService() : _query = OnAudioQuery();

  final OnAudioQuery _query;

  @override
  Future<bool> hasPermission() => _query.permissionsStatus();

  @override
  Future<bool> requestPermission() => _query.permissionsRequest();

  @override
  Future<List<DeviceTrack>> queryTracks() async {
    final songs = await _query.querySongs();
    return songs
        .where((song) => song.isMusic ?? true)
        .map(
          (song) => DeviceTrack(
            deviceAudioId: song.id,
            filePath: song.data,
            title: song.title,
            artist: song.artist,
            album: song.album,
            durationMs: song.duration ?? 0,
          ),
        )
        .toList();
  }
}

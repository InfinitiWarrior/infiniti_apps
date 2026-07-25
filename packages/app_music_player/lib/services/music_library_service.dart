import 'package:flutter/services.dart';
import 'package:on_audio_query/on_audio_query.dart';

import 'device_track.dart';

/// Device media-library access. Abstracted so widget tests and Linux dev
/// iteration never touch the real `on_audio_query` platform channel, which
/// (like `record`) has no Linux implementation.
abstract class MusicLibraryService {
  Future<bool> hasPermission();
  Future<bool> requestPermission();
  Future<List<DeviceTrack>> queryTracks();

  /// Requests OS-level deletion of device media files by their
  /// `deviceAudioId`s. These are files this app didn't create, so on
  /// Android 11+ (scoped storage) deletion goes through the OS's own
  /// confirmation dialog rather than a direct file delete — it's an
  /// all-or-nothing grant for the whole batch, never a silent/partial one.
  Future<bool> deleteDeviceAudio(List<int> deviceAudioIds);
}

class PlatformMusicLibraryService implements MusicLibraryService {
  PlatformMusicLibraryService() : _query = OnAudioQuery();

  final OnAudioQuery _query;

  static const _mediaStoreChannel = MethodChannel(
    'com.infinitiwarrior.musicplayer/media_store',
  );

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

  @override
  Future<bool> deleteDeviceAudio(List<int> deviceAudioIds) async {
    if (deviceAudioIds.isEmpty) return true;
    final confirmed = await _mediaStoreChannel.invokeMethod<bool>(
      'deleteAudio',
      {'ids': deviceAudioIds},
    );
    return confirmed ?? false;
  }
}

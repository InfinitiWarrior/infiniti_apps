import 'device_track.dart';
import 'music_library_service.dart';

/// Seeded stand-in for [MusicLibraryService] used on Linux, where
/// `on_audio_query` has no desktop implementation. UI/layout iteration only —
/// real library scanning is verified on the physical device.
class FakeMusicLibraryService implements MusicLibraryService {
  @override
  Future<bool> hasPermission() async => true;

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<List<DeviceTrack>> queryTracks() async => [
    DeviceTrack(
      deviceAudioId: 1,
      filePath: '/dev/null/fake1.mp3',
      title: 'Sample Track One',
      artist: 'Fake Artist',
      album: 'Desktop Preview',
      durationMs: const Duration(minutes: 3, seconds: 12).inMilliseconds,
    ),
    DeviceTrack(
      deviceAudioId: 2,
      filePath: '/dev/null/fake2.mp3',
      title: 'Sample Track Two',
      artist: 'Fake Artist',
      album: 'Desktop Preview',
      durationMs: const Duration(minutes: 4, seconds: 1).inMilliseconds,
    ),
    DeviceTrack(
      deviceAudioId: 3,
      filePath: '/dev/null/fake3.mp3',
      title: 'Sample Track Three',
      artist: 'Another Artist',
      album: 'Desktop Preview',
      durationMs: const Duration(minutes: 2, seconds: 47).inMilliseconds,
    ),
  ];
}

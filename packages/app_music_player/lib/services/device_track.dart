/// A track as reported by the device's media store, independent of drift.
class DeviceTrack {
  DeviceTrack({
    required this.deviceAudioId,
    required this.filePath,
    required this.title,
    required this.durationMs,
    this.artist,
    this.album,
  });

  final int deviceAudioId;
  final String filePath;
  final String title;
  final String? artist;
  final String? album;
  final int durationMs;
}

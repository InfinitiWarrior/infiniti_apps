import 'package:record/record.dart';

import 'recording_format.dart';

/// Recording control surface. Abstracted so widget tests can supply a fake
/// instead of touching the real `record` platform channel.
abstract class AudioRecorderService {
  Future<bool> hasPermission();
  Future<void> start(String filePath, RecordingFormat format);
  Future<void> pause();
  Future<void> resume();
  Future<String?> stop();
  Future<void> cancel();
  Future<bool> isRecording();
  void dispose();
}

class PlatformAudioRecorderService implements AudioRecorderService {
  PlatformAudioRecorderService() : _recorder = AudioRecorder();

  final AudioRecorder _recorder;

  @override
  Future<bool> hasPermission() => _recorder.hasPermission();

  @override
  Future<void> start(String filePath, RecordingFormat format) {
    return _recorder.start(RecordConfig(encoder: format.encoder), path: filePath);
  }

  @override
  Future<void> pause() => _recorder.pause();

  @override
  Future<void> resume() => _recorder.resume();

  @override
  Future<String?> stop() => _recorder.stop();

  @override
  Future<void> cancel() => _recorder.cancel();

  @override
  Future<bool> isRecording() => _recorder.isRecording();

  @override
  void dispose() => _recorder.dispose();
}

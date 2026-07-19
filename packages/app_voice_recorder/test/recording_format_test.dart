import 'package:app_voice_recorder/services/recording_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('extensions match the format', () {
    expect(RecordingFormat.aac.extension, 'm4a');
    expect(RecordingFormat.wav.extension, 'wav');
  });

  test('fromName round-trips and falls back to AAC', () {
    expect(RecordingFormat.fromName('wav'), RecordingFormat.wav);
    expect(RecordingFormat.fromName('aac'), RecordingFormat.aac);
    expect(RecordingFormat.fromName('unknown'), RecordingFormat.aac);
  });
}

import 'package:record/record.dart';

enum RecordingFormat {
  aac('AAC', 'm4a', AudioEncoder.aacLc),
  wav('WAV', 'wav', AudioEncoder.wav);

  const RecordingFormat(this.label, this.extension, this.encoder);

  final String label;
  final String extension;
  final AudioEncoder encoder;

  static RecordingFormat fromName(String name) {
    return RecordingFormat.values.firstWhere(
      (f) => f.name == name,
      orElse: () => RecordingFormat.aac,
    );
  }
}

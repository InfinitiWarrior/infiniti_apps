import 'dart:io';

import 'transcode_service.dart';

/// Stand-in for [TranscodeService] used on Linux and in tests
/// (ffmpeg_kit_flutter_new has no Linux implementation). Just renames/copies
/// the source file(s) to the destination rather than really transcoding, so
/// the rest of the download pipeline can still be exercised end-to-end.
class FakeTranscodeService implements TranscodeService {
  @override
  Future<void> transcodeToMp3({
    required String sourcePath,
    required String destinationPath,
    required String title,
    String? artist,
    String? album,
  }) async {
    await File(sourcePath).copy(destinationPath);
    await File(sourcePath).delete();
  }

  @override
  Future<void> muxToMp4({
    required String videoPath,
    required String audioPath,
    required String destinationPath,
  }) async {
    await File(videoPath).copy(destinationPath);
    await File(videoPath).delete();
    await File(audioPath).delete();
  }
}

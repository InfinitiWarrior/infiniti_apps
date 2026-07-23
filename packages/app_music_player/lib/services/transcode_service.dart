import 'dart:io';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';

class TranscodeException implements Exception {
  TranscodeException(this.message);

  final String message;

  @override
  String toString() => 'TranscodeException: $message';
}

/// FFmpeg-backed audio transcoding and video muxing. Abstracted so widget
/// tests and Linux dev iteration (ffmpeg_kit_flutter_new has no Linux
/// implementation) never touch the real platform channel.
abstract class TranscodeService {
  /// Transcodes the raw audio at [sourcePath] into a real MP3 at
  /// [destinationPath], embedding ID3 tags. Deletes [sourcePath] on success.
  Future<void> transcodeToMp3({
    required String sourcePath,
    required String destinationPath,
    required String title,
    String? artist,
    String? album,
  });

  /// Muxes the video-only [videoPath] and audio-only [audioPath] (stream
  /// copy, no re-encoding) into an MP4 at [destinationPath]. Deletes both
  /// source files on success.
  Future<void> muxToMp4({
    required String videoPath,
    required String audioPath,
    required String destinationPath,
  });
}

class PlatformTranscodeService implements TranscodeService {
  Future<void> _run(List<String> arguments) async {
    final session = await FFmpegKit.executeWithArguments(arguments);
    final returnCode = await session.getReturnCode();
    if (!ReturnCode.isSuccess(returnCode)) {
      // getFailStackTrace() is for a plugin-level Java exception, which is
      // rare — an ffmpeg command failure (wrong codec, bad args, etc.) shows
      // up in the process's own logs instead, so prefer those. Both can
      // come back as an empty string rather than null, so `??` alone isn't
      // enough to skip them.
      final logs = await session.getAllLogsAsString();
      final failStackTrace = await session.getFailStackTrace();
      final failure = _firstNonEmpty([
            logs,
            failStackTrace,
          ]) ??
          'ffmpeg failed with no diagnostic output (return code: $returnCode)';
      throw TranscodeException(failure);
    }
  }

  String? _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      if (value != null && value.trim().isNotEmpty) return value;
    }
    return null;
  }

  @override
  Future<void> transcodeToMp3({
    required String sourcePath,
    required String destinationPath,
    required String title,
    String? artist,
    String? album,
  }) async {
    await _run([
      '-y',
      '-i',
      sourcePath,
      '-vn',
      '-c:a',
      'libmp3lame',
      '-b:a',
      '192k',
      '-metadata',
      'title=$title',
      if (artist != null) ...['-metadata', 'artist=$artist'],
      if (album != null) ...['-metadata', 'album=$album'],
      destinationPath,
    ]);
    await File(sourcePath).delete();
  }

  @override
  Future<void> muxToMp4({
    required String videoPath,
    required String audioPath,
    required String destinationPath,
  }) async {
    await _run([
      '-y',
      '-i',
      videoPath,
      '-i',
      audioPath,
      '-c',
      'copy',
      destinationPath,
    ]);
    await File(videoPath).delete();
    await File(audioPath).delete();
  }
}

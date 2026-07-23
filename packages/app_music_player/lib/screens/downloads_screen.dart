import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../controllers/playback_controller.dart';
import '../database/music_database.dart';
import '../repositories/download_repository.dart';
import '../repositories/music_repository.dart';
import '../services/download_format.dart';
import '../widgets/download_task_tile.dart';
import 'video_player_screen.dart';

class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({
    super.key,
    required this.downloadRepository,
    required this.musicRepository,
    required this.playbackController,
  });

  final DownloadRepository downloadRepository;
  final MusicRepository musicRepository;
  final PlaybackController playbackController;

  Future<void> _openCompleted(BuildContext context, DownloadTask task) async {
    if (DownloadFormat.fromName(task.format) == DownloadFormat.mp3) {
      if (task.trackId == null) return;
      final track = await musicRepository.getTrack(task.trackId!);
      if (track != null) {
        await playbackController.playTracks([track]);
      }
      return;
    }

    if (!(Platform.isAndroid || Platform.isIOS)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Video preview is only available on device.'),
          ),
        );
      }
      return;
    }
    if (task.filePath == null || !context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            VideoPlayerScreen(title: task.title, filePath: task.filePath!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const InfinitiAppBar(title: 'Downloads'),
      // Plain select — safe to call inline in build() per drift's key cache.
      body: StreamBuilder<List<DownloadTask>>(
        stream: downloadRepository.watchDownloadTasks(),
        builder: (context, snapshot) {
          final tasks = snapshot.data ?? const <DownloadTask>[];
          if (tasks.isEmpty) {
            return const EmptyState(
              icon: Icons.download_outlined,
              message: 'No downloads yet.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            itemCount: tasks.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final task = tasks[index];
              return DownloadTaskTile(
                task: task,
                onTap: () => _openCompleted(context, task),
                onRetry: () => downloadRepository.retry(task.id),
                onRemove: () => downloadRepository.remove(task.id),
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../controllers/playback_controller.dart';
import '../services/repeat_mode.dart';
import '../utils/duration_format.dart';
import 'queue_screen.dart';
import '../repositories/music_repository.dart';

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({
    super.key,
    required this.controller,
    required this.repository,
  });

  final PlaybackController controller;
  final MusicRepository repository;

  IconData _repeatIcon(PlayerRepeatMode mode) {
    return switch (mode) {
      PlayerRepeatMode.off => Icons.repeat,
      PlayerRepeatMode.all => Icons.repeat_on,
      PlayerRepeatMode.one => Icons.repeat_one_on,
    };
  }

  void _cycleRepeatMode() {
    final next = switch (controller.repeatMode) {
      PlayerRepeatMode.off => PlayerRepeatMode.all,
      PlayerRepeatMode.all => PlayerRepeatMode.one,
      PlayerRepeatMode.one => PlayerRepeatMode.off,
    };
    controller.setRepeatMode(next);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: InfinitiAppBar(
        title: 'Now Playing',
        actions: [
          IconButton(
            icon: const Icon(Icons.queue_music),
            tooltip: 'Queue',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => QueueScreen(
                  repository: repository,
                  playbackController: controller,
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final track = controller.currentTrack;
          if (track == null) {
            return const EmptyState(
              icon: Icons.music_off,
              message: 'Nothing playing.',
            );
          }
          final duration =
              controller.duration ?? Duration(milliseconds: track.durationMs);
          final position = controller.position > duration
              ? duration
              : controller.position;

          return Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.album,
                  size: 160,
                  color: AppColors.surface2,
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  track.title,
                  style: AppTextStyles.headline,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (track.artist != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    track.artist!,
                    style: AppTextStyles.bodyMuted,
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                Slider(
                  value: position.inMilliseconds
                      .clamp(0, duration.inMilliseconds)
                      .toDouble(),
                  max: duration.inMilliseconds.toDouble().clamp(
                    1,
                    double.infinity,
                  ),
                  onChanged: (value) =>
                      controller.seek(Duration(milliseconds: value.round())),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(formatDuration(position), style: AppTextStyles.caption),
                      Text(formatDuration(duration), style: AppTextStyles.caption),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.shuffle,
                        color: controller.shuffleEnabled
                            ? AppColors.mauve
                            : AppColors.subtext0,
                      ),
                      onPressed: () => controller.setShuffleEnabled(
                        !controller.shuffleEnabled,
                      ),
                    ),
                    IconButton(
                      iconSize: 36,
                      icon: const Icon(Icons.skip_previous),
                      onPressed: controller.skipPrevious,
                    ),
                    IconButton(
                      iconSize: 56,
                      icon: Icon(
                        controller.isPlaying
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_filled,
                      ),
                      onPressed: controller.togglePlayPause,
                    ),
                    IconButton(
                      iconSize: 36,
                      icon: const Icon(Icons.skip_next),
                      onPressed: controller.skipNext,
                    ),
                    IconButton(
                      icon: Icon(
                        _repeatIcon(controller.repeatMode),
                        color: controller.repeatMode == PlayerRepeatMode.off
                            ? AppColors.subtext0
                            : AppColors.mauve,
                      ),
                      onPressed: _cycleRepeatMode,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

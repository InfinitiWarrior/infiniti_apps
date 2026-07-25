import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../controllers/playback_controller.dart';

/// Persistent mini-player docked above the bottom nav bar. Tap to open the
/// full [NowPlayingScreen].
class NowPlayingBar extends StatelessWidget {
  const NowPlayingBar({
    super.key,
    required this.controller,
    required this.onTap,
  });

  final PlaybackController controller;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final track = controller.currentTrack;
        if (track == null) return const SizedBox.shrink();
        return Material(
          color: AppColors.surface1,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  const Icon(Icons.music_note, color: AppColors.mauve),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          track.title,
                          style: AppTextStyles.body,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (track.artist != null)
                          Text(
                            track.artist!,
                            style: AppTextStyles.caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      controller.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                    ),
                    onPressed: controller.togglePlayPause,
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next),
                    onPressed: controller.skipNext,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'Stop',
                    onPressed: controller.stop,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

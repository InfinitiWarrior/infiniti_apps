import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../utils/duration_format.dart';

enum RecorderState { idle, recording, paused }

class RecordingControls extends StatelessWidget {
  const RecordingControls({
    super.key,
    required this.state,
    required this.elapsed,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onStop,
  });

  final RecorderState state;
  final Duration elapsed;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Text(
            formatDuration(elapsed),
            style: AppTextStyles.displayLarge.copyWith(
              color: state == RecorderState.idle ? AppColors.overlay : AppColors.text,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (state == RecorderState.idle)
            _RoundButton(
              icon: Icons.mic,
              background: AppColors.red,
              onPressed: onStart,
              tooltip: 'Start recording',
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _RoundButton(
                  icon: state == RecorderState.recording ? Icons.pause : Icons.mic,
                  background: AppColors.surface1,
                  size: 56,
                  onPressed: state == RecorderState.recording ? onPause : onResume,
                  tooltip: state == RecorderState.recording ? 'Pause' : 'Resume',
                ),
                const SizedBox(width: AppSpacing.lg),
                _RoundButton(
                  icon: Icons.stop,
                  background: AppColors.red,
                  onPressed: onStop,
                  tooltip: 'Stop and save',
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.background,
    required this.onPressed,
    required this.tooltip,
    this.size = 72,
  });

  final IconData icon;
  final Color background;
  final VoidCallback onPressed;
  final String tooltip;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Tooltip(
          message: tooltip,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(icon, color: AppColors.crust, size: size * 0.5),
          ),
        ),
      ),
    );
  }
}

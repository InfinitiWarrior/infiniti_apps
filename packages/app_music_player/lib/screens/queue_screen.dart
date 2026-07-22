import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../controllers/playback_controller.dart';
import '../database/music_database.dart';
import '../repositories/music_repository.dart';
import '../widgets/track_tile.dart';

class QueueScreen extends StatefulWidget {
  const QueueScreen({
    super.key,
    required this.repository,
    required this.playbackController,
  });

  final MusicRepository repository;
  final PlaybackController playbackController;

  @override
  State<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends State<QueueScreen> {
  // Cached rather than created inline in build(): this is a joined query, so
  // a fresh Stream on every rebuild would make StreamBuilder cancel and
  // resubscribe every frame.
  late final Stream<List<QueueEntry>> _queueStream = widget.repository
      .watchQueue();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: InfinitiAppBar(
        title: 'Queue',
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            tooltip: 'Clear queue',
            onPressed: widget.repository.clearQueue,
          ),
        ],
      ),
      body: StreamBuilder<List<QueueEntry>>(
        stream: _queueStream,
        builder: (context, snapshot) {
          final entries = snapshot.data ?? const <QueueEntry>[];
          if (entries.isEmpty) {
            return const EmptyState(
              icon: Icons.queue_music_outlined,
              message: 'Queue is empty.',
            );
          }
          return ListenableBuilder(
            listenable: widget.playbackController,
            builder: (context, _) {
              return ReorderableListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                itemCount: entries.length,
                onReorderItem: (oldIndex, newIndex) {
                  final reordered = [...entries];
                  final moved = reordered.removeAt(oldIndex);
                  reordered.insert(newIndex, moved);
                  widget.playbackController.reorderQueue(
                    reordered.map((e) => e.queueItemId).toList(),
                    reordered.map((e) => e.track).toList(),
                  );
                },
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  final isCurrent =
                      widget.playbackController.currentIndex == index;
                  return TrackTile(
                    key: ValueKey(entry.queueItemId),
                    track: entry.track,
                    isCurrent: isCurrent,
                    onTap: () => widget.playbackController.skipToIndex(index),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      tooltip: 'Remove from queue',
                      onPressed: () => widget.playbackController
                          .removeFromQueueAt(index, entry.queueItemId),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Simple full-screen preview for downloaded MP4s. Only ever pushed from a
/// Platform.isAndroid/isIOS-guarded call site — `video_player` (like
/// `on_audio_query`) has no meaningful Linux desktop story.
class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key, required this.title, required this.filePath});

  final String title;
  final String filePath;

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late final VideoPlayerController _controller;
  late final Future<void> _initialized;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.filePath));
    _initialized = _controller.initialize().then((_) {
      _controller.play();
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: InfinitiAppBar(title: widget.title),
      body: FutureBuilder<void>(
        future: _initialized,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const LoadingIndicator();
          }
          return Center(
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  VideoPlayer(_controller),
                  VideoProgressIndicator(_controller, allowScrubbing: true),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() {
          _controller.value.isPlaying ? _controller.pause() : _controller.play();
        }),
        child: ValueListenableBuilder<VideoPlayerValue>(
          valueListenable: _controller,
          builder: (context, value, _) =>
              Icon(value.isPlaying ? Icons.pause : Icons.play_arrow),
        ),
      ),
    );
  }
}

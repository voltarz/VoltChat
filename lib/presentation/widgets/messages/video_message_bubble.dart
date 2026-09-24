import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../domain/models/message.dart';

class VideoMessageBubble extends StatefulWidget {
  final Message message;
  final bool isMe;

  const VideoMessageBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  State<VideoMessageBubble> createState() => _VideoMessageBubbleState();
}

class _VideoMessageBubbleState extends State<VideoMessageBubble> {
  void _openVideoPlayer(BuildContext context) {
    if (widget.message.localPath == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullScreenVideoPlayer(localPath: widget.message.localPath!),
      ),
    );
  }

  String _formatDuration(int? seconds) {
    if (seconds == null) return "0:00";
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return "$m:${s.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: widget.isMe ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => _openVideoPlayer(context),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 250,
                  height: 250,
                  color: Colors.black87,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Placeholder icon
                      const Icon(Icons.videocam, size: 50, color: Colors.white54),
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.black45,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.play_arrow, size: 50, color: Colors.white),
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _formatDuration(widget.message.duration),
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            if (widget.message.content.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, top: 4),
                child: Text(
                  widget.message.content,
                  style: TextStyle(
                    color: widget.isMe ? Colors.black : Colors.white,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 4, left: 8, top: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${widget.message.sentAt.hour}:${widget.message.sentAt.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 10,
                      color: widget.isMe ? Colors.black54 : Colors.white54,
                    ),
                  ),
                  if (widget.isMe) ...[
                    const SizedBox(width: 4),
                    Icon(
                      widget.message.isRead ? Icons.done_all : Icons.check,
                      size: 14,
                      color: Colors.black54,
                    ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FullScreenVideoPlayer extends StatefulWidget {
  final String localPath;

  const FullScreenVideoPlayer({super.key, required this.localPath});

  @override
  State<FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.localPath))
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {
          _initialized = true;
        });
        _controller.play();
      }).catchError((e) {
        if (!mounted) return;
        setState(() {
          _error = true;
        });
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: _error
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 50),
                  SizedBox(height: 16),
                  Text('Failed to load video.', style: TextStyle(color: Colors.white)),
                ],
              )
            : _initialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        VideoPlayer(_controller),
                        VideoProgressIndicator(_controller, allowScrubbing: true),
                        Center(
                          child: IconButton(
                            iconSize: 64,
                            icon: Icon(
                              _controller.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                              color: Colors.white.withAlpha(200),
                            ),
                            onPressed: () {
                              setState(() {
                                _controller.value.isPlaying ? _controller.pause() : _controller.play();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                : const CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}

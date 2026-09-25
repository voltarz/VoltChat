import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class VoiceNotePreviewDialog extends StatefulWidget {
  final File file;
  final int duration;

  const VoiceNotePreviewDialog({super.key, required this.file, required this.duration});

  @override
  State<VoiceNotePreviewDialog> createState() => _VoiceNotePreviewDialogState();
}

class _VoiceNotePreviewDialogState extends State<VoiceNotePreviewDialog> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Review Voice Note'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Voice note recorded (${widget.duration}s).'),
          const SizedBox(height: 16),
          IconButton(
            iconSize: 48,
            icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled),
            onPressed: () {
              if (_isPlaying) {
                _audioPlayer.pause();
              } else {
                _audioPlayer.play(DeviceFileSource(widget.file.path));
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.file.delete();
            Navigator.pop(context, false);
          },
          child: const Text('Discard'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, true);
          },
          child: const Text('Send'),
        ),
      ],
    );
  }
}

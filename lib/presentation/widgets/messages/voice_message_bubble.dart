import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../domain/models/message.dart';
import '../../../data/services/local_media_storage_service.dart';

class VoiceMessageBubble extends StatefulWidget {
  final Message message;
  final bool isMe;

  const VoiceMessageBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  State<VoiceMessageBubble> createState() => _VoiceMessageBubbleState();
}

class _VoiceMessageBubbleState extends State<VoiceMessageBubble> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerStateChangeSubscription;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    // Fallback if message has stored duration but audio player hasn't loaded it yet
    if (widget.message.duration != null) {
      _duration = Duration(seconds: widget.message.duration!);
    }

    _setupAudioPlayer();
  }

  void _setupAudioPlayer() {
    if (widget.message.localPath == null) return;

    final resolvedPath = LocalMediaStorageService().getResolvedPath(widget.message.localPath!);
    if (resolvedPath == null) return;

    _audioPlayer.setSourceDeviceFile(resolvedPath);

    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) setState(() => _duration = duration);
    });

    _positionSubscription = _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) setState(() => _position = position);
    });

    _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      }
    });

    _playerStateChangeSubscription = _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });
  }

  @override
  void dispose() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerStateChangeSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _togglePlayPause() async {
    if (widget.message.localPath == null) return;

    final resolvedPath = LocalMediaStorageService().getResolvedPath(widget.message.localPath!);
    if (resolvedPath == null) return;

    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(DeviceFileSource(resolvedPath));
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          color: widget.isMe ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: widget.isMe ? Colors.black87 : Colors.white,
              ),
              onPressed: _togglePlayPause,
            ),
            Expanded(
              child: Slider(
                activeColor: widget.isMe ? Colors.black87 : Theme.of(context).primaryColor,
                inactiveColor: widget.isMe ? Colors.black26 : Colors.white24,
                min: 0,
                max: _duration.inMilliseconds.toDouble() > 0 ? _duration.inMilliseconds.toDouble() : 1,
                value: _position.inMilliseconds.toDouble().clamp(0, _duration.inMilliseconds.toDouble() > 0 ? _duration.inMilliseconds.toDouble() : 1),
                onChanged: (value) async {
                  final position = Duration(milliseconds: value.toInt());
                  await _audioPlayer.seek(position);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatDuration(_position.inMilliseconds > 0 ? _position : _duration),
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.isMe ? Colors.black87 : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
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
                          size: 12,
                          color: Colors.black54,
                        ),
                      ]
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../../../domain/models/message.dart';
import 'package:video_player/video_player.dart';
import '../../../domain/models/message_type.dart';
import '../../../data/services/mock_messaging_service.dart';
import '../../../domain/models/contact.dart';
import '../../../data/services/mock_contact_service.dart';
import '../../../data/services/local_media_storage_service.dart';
import '../../../core/utils/attachment_picker.dart';
import '../../widgets/messages/text_message_bubble.dart';
import '../../widgets/messages/image_message_bubble.dart';
import '../../widgets/messages/video_message_bubble.dart';
import '../../widgets/messages/file_message_bubble.dart';
import '../../widgets/messages/voice_message_bubble.dart';
import 'package:swipe_to/swipe_to.dart';
import '../../widgets/messages/voice_note_preview_dialog.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;

  const ChatScreen({super.key, required this.conversationId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final MockMessagingService _messagingService = MockMessagingService();
  final MockContactService _contactService = MockContactService();
  final LocalMediaStorageService _mediaStorage = LocalMediaStorageService();
  final TextEditingController _messageController = TextEditingController();
  List<Message> _messages = [];
  bool _isLoading = true;
  Contact? _contact;

  // Voice recording state
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecordingVoice = false;
  DateTime? _recordingStartTime;
  String _recordingDuration = "0:00";

  Message? _replyingToMessage;

  @override
  void initState() {
    super.initState();
    _loadContact();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _loadContact() async {
    final id = widget.conversationId.startsWith('conv_')
        ? widget.conversationId.substring(5)
        : widget.conversationId;
    final contact = await _contactService.getContactById(id);
    if (mounted) {
      setState(() => _contact = contact);
    }
  }

  Future<void> _loadMessages() async {
    final messages = await _messagingService.getMessagesForConversation(widget.conversationId);
    if (mounted) {
      setState(() {
        _messages = messages.toList();
        _messages.sort((a, b) => b.sentAt.compareTo(a.sentAt));
        _isLoading = false;
      });
    }
  }

  void _sendMessage({
    String? contentOverride,
    MessageType messageType = MessageType.text,
    String? localPath,
    String? fileName,
    String? mimeType,
    int? fileSize,
    int? duration,
  }) {
    final content = contentOverride ?? _messageController.text.trim();
    if (content.isEmpty && localPath == null) return;

    String? replyToId = _replyingToMessage?.id;
    String? replyToSnippet;

    if (_replyingToMessage != null) {
      replyToSnippet = _replyingToMessage!.content.isNotEmpty
          ? _replyingToMessage!.content
          : _replyingToMessage!.fileName ?? messageTypeToString(_replyingToMessage!.messageType);
    }

    final newMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: widget.conversationId,
      senderId: 'me',
      content: content,
      sentAt: DateTime.now(),
      isRead: false,
      messageType: messageType,
      localPath: localPath,
      fileName: fileName,
      mimeType: mimeType,
      fileSize: fileSize,
      duration: duration,
      replyToMessageId: replyToId,
      replyToMessageSnippet: replyToSnippet,
    );

    setState(() {
      _messages.insert(0, newMessage);
      _messageController.clear();
      _replyingToMessage = null;
    });

    _messagingService.sendMessage(
      widget.conversationId,
      content,
      messageType: messageTypeToString(messageType),
      localPath: localPath,
      fileName: fileName,
      mimeType: mimeType,
      fileSize: fileSize,
      duration: duration,
      replyToMessageId: replyToId,
      replyToMessageSnippet: replyToSnippet,
    );
  }

  Future<void> _showMediaPreview(AttachmentResult result) async {
    bool send = false;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Preview Media'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (result.type == 'image')
                  Image.file(result.file, height: 200)
                else if (result.type == 'video')
                  const Icon(Icons.videocam, size: 100)
                else if (result.type == 'file')
                  Column(
                    children: [
                      const Icon(Icons.insert_drive_file, size: 50),
                      Text(result.originalName),
                    ],
                  ),
                const SizedBox(height: 16),
                const Text('Do you want to send this attachment?'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                send = true;
                Navigator.pop(context);
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );

    if (send) {
      await _processAttachment(result);
    }
  }

  Future<void> _handleAttachmentSelection() async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.pop(context);
                  final result = await AttachmentPicker.takePhoto();
                  if (result != null) _showMediaPreview(result);
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text('Record Video'),
                onTap: () async {
                  Navigator.pop(context);
                  final result = await AttachmentPicker.recordVideo();
                  if (result != null) _showMediaPreview(result);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Gallery (Image/Video)'),
                onTap: () async {
                  Navigator.pop(context);
                  showDialog(context: context, builder: (context) => AlertDialog(
                    title: const Text('Select Media'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: const Text('Image'),
                          onTap: () async {
                            Navigator.pop(context);
                            final result = await AttachmentPicker.pickImageFromGallery();
                            if (result != null) _showMediaPreview(result);
                          }
                        ),
                        ListTile(
                          title: const Text('Video'),
                          onTap: () async {
                            Navigator.pop(context);
                            final result = await AttachmentPicker.pickVideoFromGallery();
                            if (result != null) _showMediaPreview(result);
                          }
                        )
                      ]
                    )
                  ));
                },
              ),
              ListTile(
                leading: const Icon(Icons.insert_drive_file),
                title: const Text('Document / File'),
                onTap: () async {
                  Navigator.pop(context);
                  final result = await AttachmentPicker.pickFile();
                  if (result != null) _showMediaPreview(result);
                },
              ),
              ListTile(
                leading: const Icon(Icons.mic),
                title: const Text('Record Voice / Voice Note'),
                onTap: () async {
                  Navigator.pop(context);
                  _toggleVoiceRecord();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<int?> _getVideoDuration(File file) async {
    try {
      final controller = VideoPlayerController.file(file);
      await controller.initialize();
      final duration = controller.value.duration.inSeconds;
      await controller.dispose();
      return duration;
    } catch (e) {
      return null;
    }
  }

  Future<void> _processAttachment(AttachmentResult result) async {
    final savedPath = await _mediaStorage.saveMediaFile(result.file, result.originalName);

    MessageType type = MessageType.text;
    int? duration;

    if (result.type == 'image') type = MessageType.image;
    if (result.type == 'file') type = MessageType.file;
    if (result.type == 'video') {
      type = MessageType.video;
      duration = await _getVideoDuration(result.file);
    }

    _sendMessage(
      contentOverride: '', // Or prompt user for caption
      messageType: type,
      localPath: savedPath,
      fileName: result.originalName,
      fileSize: result.size,
      duration: duration,
    );
  }

  Future<void> _toggleVoiceRecord() async {
    if (_isRecordingVoice) {
      // Stop recording
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecordingVoice = false;
      });

      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          final duration = DateTime.now().difference(_recordingStartTime!).inSeconds;

          if (!mounted) return;
          final send = await showDialog<bool>(
            context: context,
            builder: (dialogContext) {
              return VoiceNotePreviewDialog(file: file, duration: duration);
            },
          ) ?? false;

          if (send) {
            final savedPath = await _mediaStorage.saveMediaFile(file, 'voice_note_${DateTime.now().millisecondsSinceEpoch}.m4a');
            final size = await file.length();

            _sendMessage(
              contentOverride: '',
              messageType: MessageType.audio,
              localPath: savedPath,
              fileName: 'Voice Note',
              fileSize: size,
              duration: duration,
            );
          }
        }
      }
    } else {
      // Start recording
      if (!Platform.isWindows && !Platform.isLinux) {
        final status = await Permission.microphone.request();
        if (status != PermissionStatus.granted) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Microphone permission required.'),
              action: SnackBarAction(label: 'Settings', onPressed: () => openAppSettings()),
            )
          );
          return;
        }
      }

      if (await _audioRecorder.hasPermission()) {
        final appDir = await getApplicationDocumentsDirectory();
        final path = '${appDir.path}/temp_voice_note.m4a';

        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: path
        );

        setState(() {
          _isRecordingVoice = true;
          _recordingStartTime = DateTime.now();
        });

        _updateRecordingDuration();
      }
    }
  }

  void _updateRecordingDuration() async {
    while (_isRecordingVoice && mounted) {
      await Future.delayed(const Duration(seconds: 1));
      if (!_isRecordingVoice || !mounted) break;

      final diff = DateTime.now().difference(_recordingStartTime!);
      final m = diff.inMinutes;
      final s = diff.inSeconds % 60;
      setState(() {
        _recordingDuration = "$m:${s.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[800],
              child: Text(
                _contact?.displayName.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            const SizedBox(width: 12),
            Text(_contact?.displayName ?? 'User'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    reverse: true,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isMe = message.senderId == 'me';

                      // Date separator logic
                      bool showDateSeparator = false;
                      if (index == _messages.length - 1) {
                        showDateSeparator = true;
                      } else {
                        final previousMessage = _messages[index + 1];
                        if (message.sentAt.year != previousMessage.sentAt.year ||
                            message.sentAt.month != previousMessage.sentAt.month ||
                            message.sentAt.day != previousMessage.sentAt.day) {
                          showDateSeparator = true;
                        }
                      }

                      Widget messageWidget;
                      switch (message.messageType) {
                        case MessageType.image:
                          messageWidget = ImageMessageBubble(message: message, isMe: isMe);
                          break;
                        case MessageType.video:
                          messageWidget = VideoMessageBubble(message: message, isMe: isMe);
                          break;
                        case MessageType.file:
                          messageWidget = FileMessageBubble(message: message, isMe: isMe);
                          break;
                        case MessageType.audio:
                          messageWidget = VoiceMessageBubble(message: message, isMe: isMe);
                          break;
                        default:
                          messageWidget = TextMessageBubble(message: message, isMe: isMe);
                          break;
                      }

                      messageWidget = SwipeTo(
                        onRightSwipe: (details) {
                          _handleReply(message);
                        },
                        child: GestureDetector(
                          onLongPress: () {
                            _showContextMenu(message);
                          },
                          child: messageWidget,
                        ),
                      );

                      if (showDateSeparator) {
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey[900],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _formatDate(message.sentAt),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ),
                            ),
                            messageWidget,
                          ],
                        );
                      }

                      return messageWidget;
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                if (_replyingToMessage != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      borderRadius: BorderRadius.circular(8),
                      border: Border(left: BorderSide(color: Theme.of(context).primaryColor, width: 4)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _replyingToMessage!.senderId == 'me' ? 'You' : _contact?.displayName ?? 'User',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _replyingToMessage!.content.isNotEmpty
                                    ? _replyingToMessage!.content
                                    : _replyingToMessage!.fileName ?? messageTypeToString(_replyingToMessage!.messageType),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20, color: Colors.white70),
                          onPressed: () {
                            setState(() {
                              _replyingToMessage = null;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                Row(
                  children: [
                    if (!_isRecordingVoice) ...[
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.attach_file),
                        onPressed: _handleAttachmentSelection,
                      ),
                    ] else ...[
                      Expanded(
                        child: Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Icon(Icons.mic, color: Colors.red),
                            ),
                            Text(
                              "Recording... $_recordingDuration",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(width: 8),
                    GestureDetector(
                      onLongPress: _isRecordingVoice ? null : _toggleVoiceRecord,
                      onLongPressUp: _isRecordingVoice ? _toggleVoiceRecord : null,
                      child: CircleAvatar(
                        backgroundColor: _isRecordingVoice ? Colors.red : Theme.of(context).primaryColor,
                        child: IconButton(
                          icon: Icon(
                            _isRecordingVoice ? Icons.stop : Icons.send,
                            color: _isRecordingVoice ? Colors.white : Colors.black
                          ),
                          onPressed: () {
                            if (_isRecordingVoice) {
                              _toggleVoiceRecord();
                            } else {
                              _sendMessage();
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleReply(Message message) {
    setState(() {
      _replyingToMessage = message;
    });
  }

  void _showContextMenu(Message message) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.reply),
                title: const Text('Reply'),
                onTap: () {
                  Navigator.pop(context);
                  _handleReply(message);
                },
              ),
              ListTile(
                leading: const Icon(Icons.forward),
                title: const Text('Forward'),
                onTap: () {
                  Navigator.pop(context);
                  _showForwardSheet(message);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showForwardSheet(Message message) async {
    final contacts = await _contactService.getContacts();

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (context, scrollController) {
            return SafeArea(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Forward to...',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: contacts.length,
                      itemBuilder: (context, index) {
                        final contact = contacts[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.grey[800],
                            child: Text(
                              contact.displayName.substring(0, 1).toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(contact.displayName),
                          onTap: () {
                            Navigator.pop(context);
                            _forwardMessage(message, 'conv_${contact.id}');
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _forwardMessage(Message message, String targetConversationId) {
    _messagingService.sendMessage(
      targetConversationId,
      message.content,
      messageType: messageTypeToString(message.messageType),
      localPath: message.localPath,
      fileName: message.fileName,
      mimeType: message.mimeType,
      fileSize: message.fileSize,
      duration: message.duration,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Message forwarded')),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0 && now.day == date.day) {
      return 'Today';
    } else if (difference.inDays == 1 || (difference.inDays == 0 && now.day != date.day)) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

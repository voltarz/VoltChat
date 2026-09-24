import 'package:flutter/material.dart';
import '../../../domain/models/message.dart';
import '../../../data/services/mock_messaging_service.dart';
import '../../../domain/models/contact.dart';
import '../../../data/services/mock_contact_service.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;

  const ChatScreen({super.key, required this.conversationId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final MockMessagingService _messagingService = MockMessagingService();
  final MockContactService _contactService = MockContactService();
  final TextEditingController _messageController = TextEditingController();
  List<Message> _messages = [];
  bool _isLoading = true;
  Contact? _contact;

  @override
  void initState() {
    super.initState();
    _loadContact();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
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

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final content = _messageController.text.trim();
    final newMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: widget.conversationId,
      senderId: 'me',
      content: content,
      sentAt: DateTime.now(),
      isRead: false,
    );

    setState(() {
      _messages.insert(0, newMessage);
      _messageController.clear();
    });

    // In a real app we'd call the service here
    _messagingService.sendMessage(widget.conversationId, content);
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

                      Widget messageWidget = Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isMe ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              Text(
                                message.content,
                                style: TextStyle(
                                  color: isMe ? Colors.black : Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${message.sentAt.hour}:${message.sentAt.minute.toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isMe ? Colors.black54 : Colors.white54,
                                    ),
                                  ),
                                  if (isMe) ...[
                                    const SizedBox(width: 4),
                                    Icon(
                                      message.isRead ? Icons.done_all : Icons.check,
                                      size: 14,
                                      color: Colors.black54,
                                    ),
                                  ]
                                ],
                              ),
                            ],
                          ),
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
            child: Row(
              children: [
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
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.black),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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

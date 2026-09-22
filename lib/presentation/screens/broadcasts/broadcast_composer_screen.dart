import 'package:flutter/material.dart';
import '../../../core/router/app_router.dart';
import '../../../data/services/mock_broadcast_service.dart';
import '../../../domain/models/broadcast.dart';
import '../../../domain/models/broadcast_list.dart';

class BroadcastComposerScreen extends StatefulWidget {
  final String listId;

  const BroadcastComposerScreen({super.key, required this.listId});

  @override
  State<BroadcastComposerScreen> createState() => _BroadcastComposerScreenState();
}

class _BroadcastComposerScreenState extends State<BroadcastComposerScreen> {
  final _broadcastService = MockBroadcastService();
  final _messageController = TextEditingController();

  BroadcastList? _list;
  List<Broadcast> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final list = await _broadcastService.getBroadcastListById(widget.listId);
      final messages = await _broadcastService.getBroadcastsForList(widget.listId);
      if (!mounted) return;
      setState(() {
        _list = list;
        _messages = messages;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading broadcast data: $e')),
      );
    }
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    try {
      await _broadcastService.sendBroadcast(widget.listId, content);
      _messageController.clear();
      await _loadData(); // Reload messages
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending broadcast: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_list == null) {
      return const Scaffold(body: Center(child: Text('List not found')));
    }

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              AppRouter.broadcastListDetails,
              arguments: widget.listId,
            ).then((_) => _loadData()); // Reload in case list details were modified
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_list!.name),
              Text(
                '${_list!.recipientIds.length} recipients',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true, // Show newest at the bottom
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(message.content),
                        const SizedBox(height: 4.0),
                        Text(
                          '${message.sentAt.hour}:${message.sentAt.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Theme.of(context).colorScheme.onPrimaryContainer.withAlpha(153), // 0.6 * 255 ≈ 153
                          ),
                        ),
                      ],
                    ),
                  ),
                );
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
                    decoration: const InputDecoration(
                      hintText: 'Type a broadcast message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(24.0)),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

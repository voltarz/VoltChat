import 'package:flutter/material.dart';

import '../../../core/router/app_router.dart';
import '../../../domain/models/conversation.dart';
import '../../../data/services/mock_messaging_service.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  final MockMessagingService _messagingService = MockMessagingService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conversations')),
      body: FutureBuilder<List<Conversation>>(
        future: _messagingService.getConversations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load conversations'));
          }

          final conversations = snapshot.data ?? [];
          if (conversations.isEmpty) {
            return const Center(child: Text('No conversations yet'));
          }

          return ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              return ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                title: Text('Participant: ${conversation.participantId}'),
                subtitle: Text('Last updated: ${conversation.lastUpdatedAt.toLocal()}'.split('.')[0]),
                onTap: () {
                  Navigator.of(context).pushNamed(
                    AppRouter.chat,
                    arguments: conversation.id,
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

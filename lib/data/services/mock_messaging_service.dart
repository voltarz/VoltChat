import '../../domain/models/conversation.dart';
import '../../domain/models/message.dart';
import '../../domain/repositories/messaging_repository.dart';

class MockMessagingService implements MessagingRepository {
  final List<Conversation> _conversations = [
    Conversation(id: 'conv1', participantId: 'u1', lastUpdatedAt: DateTime.now().subtract(const Duration(minutes: 5))),
    Conversation(id: 'conv2', participantId: 'u2', lastUpdatedAt: DateTime.now().subtract(const Duration(hours: 1))),
  ];

  final Map<String, List<Message>> _messages = {
    'conv1': [
      Message(id: 'm1', conversationId: 'conv1', senderId: 'u1', content: 'Hey, are we still on for today?', sentAt: DateTime.now().subtract(const Duration(minutes: 10)), isRead: true),
      Message(id: 'm2', conversationId: 'conv1', senderId: 'me', content: 'Yes, absolutely!', sentAt: DateTime.now().subtract(const Duration(minutes: 5)), isRead: true),
    ],
    'conv2': [
      Message(id: 'm3', conversationId: 'conv2', senderId: 'u2', content: 'Did you get the broadcast?', sentAt: DateTime.now().subtract(const Duration(hours: 1)), isRead: false),
    ]
  };

  @override
  Future<List<Conversation>> getConversations() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _conversations;
  }

  @override
  Future<Conversation> getConversationById(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _conversations.firstWhere((c) => c.id == id, orElse: () => Conversation(id: id, participantId: 'unknown', lastUpdatedAt: DateTime.now()));
  }

  @override
  Future<List<Message>> getMessagesForConversation(String conversationId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _messages[conversationId] ?? [];
  }

  @override
  Future<void> sendMessage(String conversationId, String content) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Stream<Message> watchNewMessages() {
    return const Stream.empty();
  }
}

import '../../domain/models/conversation.dart';
import '../../domain/models/message.dart';
import '../../domain/repositories/messaging_repository.dart';

class MockMessagingService implements MessagingRepository {
  @override
  Future<List<Conversation>> getConversations() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [];
  }

  @override
  Future<Conversation> getConversationById(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Conversation(id: id, participantId: 'p1', lastUpdatedAt: DateTime.now());
  }

  @override
  Future<List<Message>> getMessagesForConversation(String conversationId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [];
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

import '../models/conversation.dart';
import '../models/message.dart';

abstract class MessagingRepository {
  Future<List<Conversation>> getConversations();
  Future<Conversation> getConversationById(String id);
  Future<List<Message>> getMessagesForConversation(String conversationId);
  Future<void> sendMessage(String conversationId, String content);
  Stream<Message> watchNewMessages();
}

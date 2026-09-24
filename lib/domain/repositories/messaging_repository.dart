import '../models/conversation.dart';
import '../models/message.dart';

abstract class MessagingRepository {
  Future<List<Conversation>> getConversations();
  Future<Conversation> getConversationById(String id);
  Future<List<Message>> getMessagesForConversation(String conversationId);
  Future<void> sendMessage(
    String conversationId,
    String content, {
    String messageType = 'text',
    String? localPath,
    String? fileName,
    String? mimeType,
    int? fileSize,
    int? duration,
  });
  Stream<Message> watchNewMessages();
}

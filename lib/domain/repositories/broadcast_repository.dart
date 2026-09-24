import '../models/broadcast.dart';
import '../models/broadcast_list.dart';

abstract class BroadcastRepository {
  // Broadcast List management
  Future<List<BroadcastList>> getBroadcastLists();
  Future<BroadcastList> getBroadcastListById(String id);
  Future<BroadcastList> createBroadcastList(String name, List<String> recipientIds);
  Future<BroadcastList> updateBroadcastList(String id, String name, List<String> recipientIds);
  Future<void> deleteBroadcastList(String id);

  // Broadcast messaging
  Future<List<Broadcast>> getBroadcastsForList(String listId);
  Future<Broadcast> getBroadcastById(String id);
  Future<void> sendBroadcast(
    String listId,
    String content, {
    String messageType = 'text',
    String? localPath,
    String? fileName,
    String? mimeType,
    int? fileSize,
    int? duration,
  });
}

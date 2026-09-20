import '../models/broadcast.dart';

abstract class BroadcastRepository {
  Future<List<Broadcast>> getRecentBroadcasts();
  Future<Broadcast> getBroadcastById(String id);
  Future<void> sendBroadcast(String content, List<String> recipientIds);
}

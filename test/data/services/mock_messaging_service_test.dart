import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voltchat/data/services/mock_messaging_service.dart';
import 'package:voltchat/data/services/mock_broadcast_service.dart';

void main() {
  group('MockMessagingService Persistence and Delivery Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      MockMessagingService().clearStateForTest();
      MockBroadcastService().clearStateForTest();
    });

    test('Individual persistence: Send message, reload, verify message exists', () async {
      final service1 = MockMessagingService();
      await service1.sendMessageToParticipant('user_a', 'Hello User A');

      final conversations1 = await service1.getConversations();
      final convId = conversations1.firstWhere((c) => c.participantId == 'user_a').id;
      final messages1 = await service1.getMessagesForConversation(convId);
      expect(messages1.any((m) => m.content == 'Hello User A'), isTrue);

      // Reload/Reinitialize
      MockMessagingService().clearStateForTest();
      final service2 = MockMessagingService();

      final conversations2 = await service2.getConversations();
      final reloadedConvId = conversations2.firstWhere((c) => c.participantId == 'user_a').id;
      final messages2 = await service2.getMessagesForConversation(reloadedConvId);
      expect(messages2.any((m) => m.content == 'Hello User A'), isTrue);
    });

    test('Broadcast persistence: Send broadcast, reload, verify broadcast exists', () async {
      final broadcastService1 = MockBroadcastService();
      final list = await broadcastService1.createBroadcastList('My List', ['user_a', 'user_b']);
      await broadcastService1.sendBroadcast(list.id, 'Hello Broadcast');

      final broadcasts1 = await broadcastService1.getBroadcastsForList(list.id);
      expect(broadcasts1.any((b) => b.content == 'Hello Broadcast'), isTrue);

      // Reload/Reinitialize
      MockBroadcastService().clearStateForTest();
      final broadcastService2 = MockBroadcastService();

      final broadcasts2 = await broadcastService2.getBroadcastsForList(list.id);
      expect(broadcasts2.any((b) => b.content == 'Hello Broadcast'), isTrue);
    });

    test('Broadcast-to-individual delivery: 1 broadcast -> 3 independent deliveries (with persistence)', () async {
      final broadcastService = MockBroadcastService();
      final messagingService = MockMessagingService();

      final list = await broadcastService.createBroadcastList('List 3', ['user_a', 'user_b', 'user_c']);
      await broadcastService.sendBroadcast(list.id, 'Hello 3 Recipients');

      final conversations = await messagingService.getConversations();
      final convA = conversations.firstWhere((c) => c.participantId == 'user_a');
      final convB = conversations.firstWhere((c) => c.participantId == 'user_b');
      final convC = conversations.firstWhere((c) => c.participantId == 'user_c');

      // Verify the IDs are what we expect
      expect(convA.id, 'conv_user_a');
      expect(convB.id, 'conv_user_b');
      expect(convC.id, 'conv_user_c');

      final messagesA = await messagingService.getMessagesForConversation(convA.id);
      final messagesB = await messagingService.getMessagesForConversation(convB.id);
      final messagesC = await messagingService.getMessagesForConversation(convC.id);

      expect(messagesA.any((m) => m.content == 'Hello 3 Recipients'), isTrue);
      expect(messagesB.any((m) => m.content == 'Hello 3 Recipients'), isTrue);
      expect(messagesC.any((m) => m.content == 'Hello 3 Recipients'), isTrue);

      // Verify persistence through SharedPreferences reload
      MockMessagingService().clearStateForTest();
      MockBroadcastService().clearStateForTest();

      final reloadedMessagingService = MockMessagingService();

      final reloadedMessagesA = await reloadedMessagingService.getMessagesForConversation(convA.id);
      final reloadedMessagesB = await reloadedMessagingService.getMessagesForConversation(convB.id);
      final reloadedMessagesC = await reloadedMessagingService.getMessagesForConversation(convC.id);

      expect(reloadedMessagesA.any((m) => m.content == 'Hello 3 Recipients'), isTrue);
      expect(reloadedMessagesB.any((m) => m.content == 'Hello 3 Recipients'), isTrue);
      expect(reloadedMessagesC.any((m) => m.content == 'Hello 3 Recipients'), isTrue);
    });

    test('Privacy: No shared conversation created, messages are isolated', () async {
      final broadcastService = MockBroadcastService();
      final messagingService = MockMessagingService();

      final list = await broadcastService.createBroadcastList('List Privacy', ['user_x', 'user_y']);
      await broadcastService.sendBroadcast(list.id, 'Secret message');

      final conversations = await messagingService.getConversations();
      final convX = conversations.firstWhere((c) => c.participantId == 'user_x');
      final convY = conversations.firstWhere((c) => c.participantId == 'user_y');

      expect(convX.id, isNot(equals(convY.id)));

      final messagesX = await messagingService.getMessagesForConversation(convX.id);
      final messagesY = await messagingService.getMessagesForConversation(convY.id);

      expect(messagesX.length, 1);
      expect(messagesY.length, 1);
      expect(messagesX.first.content, 'Secret message');
      expect(messagesY.first.content, 'Secret message');
    });

    test('Replies: Reply exists only in the correct individual conversation', () async {
      final broadcastService = MockBroadcastService();
      final messagingService = MockMessagingService();

      final list = await broadcastService.createBroadcastList('List Reply', ['user_1', 'user_2']);
      await broadcastService.sendBroadcast(list.id, 'Are you there?');

      final conversations = await messagingService.getConversations();
      final conv1 = conversations.firstWhere((c) => c.participantId == 'user_1');
      final conv2 = conversations.firstWhere((c) => c.participantId == 'user_2');

      // User 1 replies
      await messagingService.sendMessage(conv1.id, 'Yes I am here');

      final messages1 = await messagingService.getMessagesForConversation(conv1.id);
      final messages2 = await messagingService.getMessagesForConversation(conv2.id);

      expect(messages1.any((m) => m.content == 'Yes I am here'), isTrue);
      expect(messages2.any((m) => m.content == 'Yes I am here'), isFalse);
    });
  });
}

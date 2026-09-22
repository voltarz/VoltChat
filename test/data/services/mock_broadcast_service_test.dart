import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voltchat/data/services/mock_broadcast_service.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    MockBroadcastService().clearStateForTest();
  });

  group('MockBroadcastService CRUD Operations', () {
    test('createBroadcastList adds a list with correct recipients', () async {
      final service = MockBroadcastService();
      final recipients = ['user1', 'user2'];

      final list = await service.createBroadcastList('My List', recipients);

      expect(list.name, 'My List');
      expect(list.recipientIds, recipients);

      final lists = await service.getBroadcastLists();
      expect(lists.length, 1);
      expect(lists.first.id, list.id);
    });

    test('updateBroadcastList renames and updates recipients', () async {
      final service = MockBroadcastService();
      final list = await service.createBroadcastList('Old Name', ['user1']);

      final updatedList = await service.updateBroadcastList(list.id, 'New Name', ['user1', 'user3']);

      expect(updatedList.name, 'New Name');
      expect(updatedList.recipientIds, ['user1', 'user3']);

      final fetchedList = await service.getBroadcastListById(list.id);
      expect(fetchedList.name, 'New Name');
      expect(fetchedList.recipientIds, ['user1', 'user3']);
    });

    test('deleteBroadcastList removes list and its messages', () async {
      final service = MockBroadcastService();
      final list = await service.createBroadcastList('To Delete', ['user1']);

      await service.sendBroadcast(list.id, 'Message 1');
      await service.sendBroadcast(list.id, 'Message 2');

      var messages = await service.getBroadcastsForList(list.id);
      expect(messages.length, 2);

      await service.deleteBroadcastList(list.id);

      final lists = await service.getBroadcastLists();
      expect(lists.isEmpty, true);

      messages = await service.getBroadcastsForList(list.id);
      expect(messages.isEmpty, true);
    });

    test('sendBroadcast adds a message to the list', () async {
      final service = MockBroadcastService();
      final list = await service.createBroadcastList('Test List', ['u1']);

      await service.sendBroadcast(list.id, 'Hello World!');

      final messages = await service.getBroadcastsForList(list.id);
      expect(messages.length, 1);
      expect(messages.first.content, 'Hello World!');
      expect(messages.first.listId, list.id);
    });
  });
}

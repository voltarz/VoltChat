import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/broadcast.dart';
import '../../domain/models/broadcast_list.dart';
import '../../domain/repositories/broadcast_repository.dart';
import 'mock_messaging_service.dart';

class MockBroadcastService implements BroadcastRepository {
  MockBroadcastService._privateConstructor();
  static final MockBroadcastService _instance = MockBroadcastService._privateConstructor();
  factory MockBroadcastService() => _instance;

  final List<BroadcastList> _lists = [];
  final List<Broadcast> _broadcasts = [];

  static const String _listsPrefsKey = 'voltchat_broadcast_lists';
  static const String _broadcastsPrefsKey = 'voltchat_broadcasts';
  bool _isInitialized = false;

  // Added for testing purposes to reset the singleton state
  void clearStateForTest() {
    _lists.clear();
    _broadcasts.clear();
    _isInitialized = false;
  }

  Future<void> _init() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();

    // Load lists
    final listsJson = prefs.getString(_listsPrefsKey);
    if (listsJson != null) {
      final List<dynamic> decoded = jsonDecode(listsJson);
      _lists.clear();
      for (var item in decoded) {
        _lists.add(BroadcastList.fromJson(item));
      }
    }

    // Load broadcasts
    final broadcastsJson = prefs.getString(_broadcastsPrefsKey);
    if (broadcastsJson != null) {
      final List<dynamic> decoded = jsonDecode(broadcastsJson);
      _broadcasts.clear();
      for (var item in decoded) {
        _broadcasts.add(Broadcast.fromJson(item));
      }
    }

    _isInitialized = true;
  }

  Future<void> _saveLists() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> jsonData = _lists.map((l) => l.toJson()).toList();
    await prefs.setString(_listsPrefsKey, jsonEncode(jsonData));
  }

  Future<void> _saveBroadcasts() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> jsonData = _broadcasts.map((b) => b.toJson()).toList();
    await prefs.setString(_broadcastsPrefsKey, jsonEncode(jsonData));
  }

  @override
  Future<List<BroadcastList>> getBroadcastLists() async {
    await _init();
    return List.unmodifiable(_lists);
  }

  @override
  Future<BroadcastList> getBroadcastListById(String id) async {
    await _init();
    return _lists.firstWhere(
      (l) => l.id == id,
      orElse: () => throw Exception('Broadcast list not found'),
    );
  }

  @override
  Future<BroadcastList> createBroadcastList(String name, List<String> recipientIds) async {
    await _init();
    final newList = BroadcastList(
      id: 'bl_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      recipientIds: recipientIds,
      createdAt: DateTime.now(),
    );
    _lists.add(newList);
    await _saveLists();
    return newList;
  }

  @override
  Future<BroadcastList> updateBroadcastList(String id, String name, List<String> recipientIds) async {
    await _init();
    final index = _lists.indexWhere((l) => l.id == id);
    if (index == -1) {
      throw Exception('Broadcast list not found');
    }

    final updatedList = BroadcastList(
      id: id,
      name: name,
      recipientIds: recipientIds,
      createdAt: _lists[index].createdAt, // Preserve original creation time
    );

    _lists[index] = updatedList;
    await _saveLists();
    return updatedList;
  }

  @override
  Future<void> deleteBroadcastList(String id) async {
    await _init();
    _lists.removeWhere((l) => l.id == id);
    // Also remove associated broadcasts
    _broadcasts.removeWhere((b) => b.listId == id);

    await _saveLists();
    await _saveBroadcasts();
  }

  @override
  Future<List<Broadcast>> getBroadcastsForList(String listId) async {
    await _init();
    return _broadcasts.where((b) => b.listId == listId).toList()
      ..sort((a, b) => b.sentAt.compareTo(a.sentAt)); // Return newest first
  }

  @override
  Future<Broadcast> getBroadcastById(String id) async {
    await _init();
    return _broadcasts.firstWhere(
      (b) => b.id == id,
      orElse: () => throw Exception('Broadcast not found'),
    );
  }

  @override
  Future<void> sendBroadcast(String listId, String content) async {
    await _init();

    // In a real app, this would also queue messages to individual recipients
    // via a background service. Here we just save the broadcast record.
    final list = await getBroadcastListById(listId);

    final broadcast = Broadcast(
      id: 'b_${DateTime.now().millisecondsSinceEpoch}',
      senderId: 'current_user', // Mock user id
      listId: list.id,
      content: content,
      sentAt: DateTime.now(),
    );

    _broadcasts.add(broadcast);
    await _saveBroadcasts();

    // Also deliver independently to each individual recipient
    final messagingService = MockMessagingService();
    for (final recipientId in list.recipientIds) {
      await messagingService.sendMessageToParticipant(recipientId, content);
    }
  }
}

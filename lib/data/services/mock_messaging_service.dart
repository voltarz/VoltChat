import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/conversation.dart';
import '../../domain/models/message.dart';
import '../../domain/repositories/messaging_repository.dart';

class MockMessagingService implements MessagingRepository {
  MockMessagingService._privateConstructor();
  static final MockMessagingService _instance = MockMessagingService._privateConstructor();
  factory MockMessagingService() => _instance;

  final List<Conversation> _conversations = [];
  final Map<String, List<Message>> _messages = {};

  static const String _conversationsPrefsKey = 'voltchat_conversations';
  static const String _messagesPrefsKey = 'voltchat_messages';
  bool _isInitialized = false;
  Future<void>? _initFuture;

  void clearStateForTest() {
    _conversations.clear();
    _messages.clear();
    _isInitialized = false;
    _initFuture = null;
  }

  Future<void> _init() async {
    if (_isInitialized) return;
    if (_initFuture != null) {
      return _initFuture;
    }
    _initFuture = _doInit();
    return _initFuture;
  }

  Future<void> _doInit() async {
    final prefs = await SharedPreferences.getInstance();

    final conversationsJson = prefs.getString(_conversationsPrefsKey);
    if (conversationsJson != null) {
      final List<dynamic> decoded = jsonDecode(conversationsJson);
      _conversations.clear();
      for (var item in decoded) {
        _conversations.add(Conversation.fromJson(item));
      }
    } else {
      _conversations.addAll([
        Conversation(id: 'conv1', participantId: 'u1', lastUpdatedAt: DateTime.now().subtract(const Duration(minutes: 5))),
        Conversation(id: 'conv2', participantId: 'u2', lastUpdatedAt: DateTime.now().subtract(const Duration(hours: 1))),
      ]);
      await _saveConversations();
    }

    final messagesJson = prefs.getString(_messagesPrefsKey);
    if (messagesJson != null) {
      final Map<String, dynamic> decoded = jsonDecode(messagesJson);
      _messages.clear();
      decoded.forEach((key, value) {
        final List<dynamic> msgList = value;
        _messages[key] = msgList.map((m) => Message.fromJson(m)).toList();
      });
    } else {
      _messages.addAll({
        'conv1': [
          Message(id: 'm1', conversationId: 'conv1', senderId: 'u1', content: 'Hey, are we still on for today?', sentAt: DateTime.now().subtract(const Duration(minutes: 10)), isRead: true),
          Message(id: 'm2', conversationId: 'conv1', senderId: 'me', content: 'Yes, absolutely!', sentAt: DateTime.now().subtract(const Duration(minutes: 5)), isRead: true),
        ],
        'conv2': [
          Message(id: 'm3', conversationId: 'conv2', senderId: 'u2', content: 'Did you get the broadcast?', sentAt: DateTime.now().subtract(const Duration(hours: 1)), isRead: false),
        ]
      });
      await _saveMessages();
    }

    _isInitialized = true;
  }

  Future<void> _saveConversations() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> jsonData = _conversations.map((c) => c.toJson()).toList();
    await prefs.setString(_conversationsPrefsKey, jsonEncode(jsonData));
  }

  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> jsonData = {};
    _messages.forEach((key, value) {
      jsonData[key] = value.map((m) => m.toJson()).toList();
    });
    await prefs.setString(_messagesPrefsKey, jsonEncode(jsonData));
  }

  @override
  Future<List<Conversation>> getConversations() async {
    await _init();
    return List.unmodifiable(_conversations);
  }

  @override
  Future<Conversation> getConversationById(String id) async {
    await _init();
    return _conversations.firstWhere((c) => c.id == id, orElse: () => Conversation(id: id, participantId: 'unknown', lastUpdatedAt: DateTime.now()));
  }

  @override
  Future<List<Message>> getMessagesForConversation(String conversationId) async {
    await _init();
    return _messages[conversationId] ?? [];
  }

  @override
  Future<void> sendMessage(String conversationId, String content) async {
    await _init();
    final now = DateTime.now();
    final newMessage = Message(
      id: 'm_${now.millisecondsSinceEpoch}',
      conversationId: conversationId,
      senderId: 'me',
      content: content,
      sentAt: now,
      isRead: true,
    );

    if (!_messages.containsKey(conversationId)) {
      _messages[conversationId] = [];
    }
    _messages[conversationId]!.add(newMessage);

    final index = _conversations.indexWhere((c) => c.id == conversationId);
    if (index != -1) {
      _conversations[index] = Conversation(
        id: conversationId,
        participantId: _conversations[index].participantId,
        broadcastOriginId: _conversations[index].broadcastOriginId,
        lastUpdatedAt: now,
      );
    } else {
      // Create conversation if it doesn't exist
      _conversations.add(Conversation(
        id: conversationId,
        participantId: 'unknown', // Best effort
        lastUpdatedAt: now,
      ));
    }

    await _saveMessages();
    await _saveConversations();
  }

  Future<void> sendMessageToParticipant(String participantId, String content) async {
    await _init();
    final index = _conversations.indexWhere((c) => c.participantId == participantId);
    String conversationId;
    if (index == -1) {
      conversationId = 'conv_${DateTime.now().millisecondsSinceEpoch}_$participantId';
      _conversations.add(Conversation(
        id: conversationId,
        participantId: participantId,
        lastUpdatedAt: DateTime.now(),
      ));
      await _saveConversations();
    } else {
      conversationId = _conversations[index].id;
    }
    await sendMessage(conversationId, content);
  }

  @override
  Stream<Message> watchNewMessages() {
    return const Stream.empty();
  }
}

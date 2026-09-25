import 'package:flutter_test/flutter_test.dart';
import 'package:voltchat/domain/models/message.dart';
import 'package:voltchat/domain/models/message_type.dart';

void main() {
  group('Message Model Serialization', () {
    test('Should deserialize a traditional text-only message', () {
      final json = {
        'id': 'msg1',
        'conversationId': 'conv1',
        'senderId': 'userA',
        'content': 'Hello old format',
        'sentAt': '2025-01-01T12:00:00.000Z',
        'isRead': true,
      };

      final msg = Message.fromJson(json);

      expect(msg.id, 'msg1');
      expect(msg.messageType, MessageType.text);
      expect(msg.localPath, isNull);
    });

    test('Should serialize and deserialize a fully populated media message', () {
      final msg = Message(
        id: 'media_msg',
        conversationId: 'conv1',
        senderId: 'userB',
        content: 'Look at this photo',
        sentAt: DateTime(2025, 1, 1, 12, 5),
        isRead: false,
        messageType: MessageType.image,
        localPath: '/storage/emulated/0/Pictures/test.png',
        fileName: 'test.png',
        mimeType: 'image/png',
        fileSize: 2048,
        duration: null,
      );

      final json = msg.toJson();

      expect(json['messageType'], 'image');
      expect(json['localPath'], '/storage/emulated/0/Pictures/test.png');
      expect(json['duration'], isNull);

      final parsedMsg = Message.fromJson(json);

      expect(parsedMsg.id, 'media_msg');
      expect(parsedMsg.messageType, MessageType.image);
      expect(parsedMsg.localPath, '/storage/emulated/0/Pictures/test.png');
      expect(parsedMsg.fileName, 'test.png');
      expect(parsedMsg.mimeType, 'image/png');
      expect(parsedMsg.fileSize, 2048);
      expect(parsedMsg.duration, isNull);
    });

    test('Should serialize and deserialize a voice note with duration', () {
      final msg = Message(
        id: 'voice_msg',
        conversationId: 'conv1',
        senderId: 'userB',
        content: '',
        sentAt: DateTime(2025, 1, 1, 12, 10),
        messageType: MessageType.audio,
        localPath: '/storage/emulated/0/Music/voice.m4a',
        duration: 35,
      );

      final json = msg.toJson();
      expect(json['duration'], 35);
      expect(json['messageType'], 'audio');

      final parsedMsg = Message.fromJson(json);
      expect(parsedMsg.messageType, MessageType.audio);
      expect(parsedMsg.duration, 35);
      expect(parsedMsg.content, '');
    });

    test('Should serialize and deserialize a video message', () {
      final msg = Message(
        id: 'video_msg',
        conversationId: 'conv1',
        senderId: 'userB',
        content: 'Check this out',
        sentAt: DateTime(2025, 1, 1, 12, 10),
        messageType: MessageType.video,
        localPath: '/storage/emulated/0/Movies/vid.mp4',
        duration: 120,
      );

      final json = msg.toJson();
      expect(json['messageType'], 'video');
      expect(json['duration'], 120);

      final parsedMsg = Message.fromJson(json);
      expect(parsedMsg.messageType, MessageType.video);
      expect(parsedMsg.localPath, '/storage/emulated/0/Movies/vid.mp4');
      expect(parsedMsg.duration, 120);
    });

    test('Should serialize and deserialize a document message', () {
      final msg = Message(
        id: 'doc_msg',
        conversationId: 'conv1',
        senderId: 'userB',
        content: 'Here is the report',
        sentAt: DateTime(2025, 1, 1, 12, 10),
        messageType: MessageType.file,
        localPath: '/storage/emulated/0/Documents/report.pdf',
        fileName: 'report.pdf',
        fileSize: 10240,
      );

      final json = msg.toJson();
      expect(json['messageType'], 'file');
      expect(json['fileName'], 'report.pdf');
      expect(json['fileSize'], 10240);

      final parsedMsg = Message.fromJson(json);
      expect(parsedMsg.messageType, MessageType.file);
      expect(parsedMsg.localPath, '/storage/emulated/0/Documents/report.pdf');
      expect(parsedMsg.fileName, 'report.pdf');
      expect(parsedMsg.fileSize, 10240);
    });

    test('Should serialize and deserialize reply metadata', () {
      final msg = Message(
        id: 'rep_1',
        conversationId: 'c1',
        senderId: 'me',
        content: 'This is a reply to the original message',
        sentAt: DateTime.parse('2023-11-20T12:00:00.000Z'),
        isRead: true,
        messageType: MessageType.text,
        replyToMessageId: 'orig_1',
        replyToMessageSnippet: 'Original message text',
      );

      final jsonMap = msg.toJson();
      final decodedMsg = Message.fromJson(jsonMap);

      expect(decodedMsg.replyToMessageId, 'orig_1');
      expect(decodedMsg.replyToMessageSnippet, 'Original message text');
      expect(decodedMsg.content, 'This is a reply to the original message');
    });
  });
}

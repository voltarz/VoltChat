import 'message_type.dart';

class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final DateTime sentAt;
  final bool isRead;
  final MessageType messageType;

  // Media attachment fields
  final String? localPath;
  final String? fileName;
  final String? mimeType;
  final int? fileSize;
  final int? duration;
  final String? thumbnailPath;

  final String? replyToMessageId;
  final String? replyToMessageSnippet;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.sentAt,
    this.isRead = false,
    this.messageType = MessageType.text,
    this.localPath,
    this.fileName,
    this.mimeType,
    this.fileSize,
    this.duration,
    this.thumbnailPath,
    this.replyToMessageId,
    this.replyToMessageSnippet,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'content': content,
      'sentAt': sentAt.toIso8601String(),
      'isRead': isRead,
      'messageType': messageTypeToString(messageType),
      if (localPath != null) 'localPath': localPath,
      if (fileName != null) 'fileName': fileName,
      if (mimeType != null) 'mimeType': mimeType,
      if (fileSize != null) 'fileSize': fileSize,
      if (duration != null) 'duration': duration,
      if (thumbnailPath != null) 'thumbnailPath': thumbnailPath,
      if (replyToMessageId != null) 'replyToMessageId': replyToMessageId,
      if (replyToMessageSnippet != null) 'replyToMessageSnippet': replyToMessageSnippet,
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      conversationId: json['conversationId'],
      senderId: json['senderId'],
      content: json['content'],
      sentAt: DateTime.parse(json['sentAt']),
      isRead: json['isRead'] ?? false,
      messageType: messageTypeFromString(json['messageType'] as String?),
      localPath: json['localPath'] as String?,
      fileName: json['fileName'] as String?,
      mimeType: json['mimeType'] as String?,
      fileSize: json['fileSize'] as int?,
      duration: json['duration'] as int?,
      thumbnailPath: json['thumbnailPath'] as String?,
      replyToMessageId: json['replyToMessageId'] as String?,
      replyToMessageSnippet: json['replyToMessageSnippet'] as String?,
    );
  }
}

import 'message_type.dart';

class Broadcast {
  final String id;
  final String senderId;
  final String listId;
  final String content;
  final DateTime sentAt;
  final MessageType messageType;

  // Media attachment fields
  final String? localPath;
  final String? fileName;
  final String? mimeType;
  final int? fileSize;
  final int? duration;
  final String? thumbnailPath;

  Broadcast({
    required this.id,
    required this.senderId,
    required this.listId,
    required this.content,
    required this.sentAt,
    this.messageType = MessageType.text,
    this.localPath,
    this.fileName,
    this.mimeType,
    this.fileSize,
    this.duration,
    this.thumbnailPath,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'listId': listId,
      'content': content,
      'sentAt': sentAt.toIso8601String(),
      'messageType': messageTypeToString(messageType),
      if (localPath != null) 'localPath': localPath,
      if (fileName != null) 'fileName': fileName,
      if (mimeType != null) 'mimeType': mimeType,
      if (fileSize != null) 'fileSize': fileSize,
      if (duration != null) 'duration': duration,
      if (thumbnailPath != null) 'thumbnailPath': thumbnailPath,
    };
  }

  factory Broadcast.fromJson(Map<String, dynamic> json) {
    return Broadcast(
      id: json['id'],
      senderId: json['senderId'],
      listId: json['listId'],
      content: json['content'],
      sentAt: DateTime.parse(json['sentAt']),
      messageType: messageTypeFromString(json['messageType'] as String?),
      localPath: json['localPath'] as String?,
      fileName: json['fileName'] as String?,
      mimeType: json['mimeType'] as String?,
      fileSize: json['fileSize'] as int?,
      duration: json['duration'] as int?,
      thumbnailPath: json['thumbnailPath'] as String?,
    );
  }
}

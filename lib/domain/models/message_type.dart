enum MessageType {
  text,
  image,
  video,
  file,
  audio,
}

MessageType messageTypeFromString(String? typeStr) {
  if (typeStr == null || typeStr.isEmpty) return MessageType.text;
  switch (typeStr) {
    case 'image':
      return MessageType.image;
    case 'video':
      return MessageType.video;
    case 'file':
      return MessageType.file;
    case 'audio':
      return MessageType.audio;
    case 'text':
    default:
      return MessageType.text;
  }
}

String messageTypeToString(MessageType type) {
  return type.name;
}

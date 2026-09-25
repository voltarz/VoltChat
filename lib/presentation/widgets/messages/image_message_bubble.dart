import 'dart:io';
import 'package:flutter/material.dart';
import '../../../domain/models/message.dart';
import '../../../data/services/local_media_storage_service.dart';

class ImageMessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const ImageMessageBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  void _showFullScreenImage(BuildContext context) {
    if (message.localPath == null) return;

    final resolvedPath = LocalMediaStorageService().getResolvedPath(message.localPath!);
    if (resolvedPath == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              child: Image.file(
                File(resolvedPath),
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, size: 100, color: Colors.white54),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resolvedPath = LocalMediaStorageService().getResolvedPath(message.localPath);
    final hasImage = resolvedPath != null && resolvedPath.isNotEmpty;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isMe ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (message.replyToMessageId != null)
              Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(8),
                  border: Border(left: BorderSide(color: isMe ? Colors.black54 : Theme.of(context).primaryColor, width: 3)),
                ),
                child: Text(
                  message.replyToMessageSnippet ?? 'Attachment',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: isMe ? Colors.black87 : Colors.white70,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            GestureDetector(
              onTap: () => _showFullScreenImage(context),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: hasImage
                    ? Image.file(
                        File(resolvedPath),
                        width: 250,
                        height: 250,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 250,
                          height: 250,
                          color: Colors.grey[800],
                          child: const Icon(Icons.broken_image, size: 50, color: Colors.white54),
                        ),
                      )
                    : Container(
                        width: 250,
                        height: 250,
                        color: Colors.grey[800],
                        child: const Icon(Icons.image_not_supported, size: 50, color: Colors.white54),
                      ),
              ),
            ),
            if (message.content.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, top: 4),
                child: Text(
                  message.content,
                  style: TextStyle(
                    color: isMe ? Colors.black : Colors.white,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 4, left: 8, top: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${message.sentAt.hour}:${message.sentAt.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 10,
                      color: isMe ? Colors.black54 : Colors.white54,
                    ),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 4),
                    Icon(
                      message.isRead ? Icons.done_all : Icons.check,
                      size: 14,
                      color: Colors.black54,
                    ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import '../../../domain/models/message.dart';

class FileMessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const FileMessageBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  void _openFile() {
    if (message.localPath != null) {
      OpenFilex.open(message.localPath!);
    }
  }

  String _formatFileSize(int? bytes) {
    if (bytes == null) return "Unknown size";
    if (bytes < 1024) return "$bytes B";
    if (bytes < 1024 * 1024) return "${(bytes / 1024).toStringAsFixed(1)} KB";
    return "${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB";
  }

  @override
  Widget build(BuildContext context) {
    final fileName = message.fileName ?? "Unknown file";
    final fileSize = _formatFileSize(message.fileSize);

    // Determine icon based on file extension
    IconData fileIcon = Icons.insert_drive_file;
    if (fileName.endsWith('.pdf')) {
      fileIcon = Icons.picture_as_pdf;
    } else if (fileName.endsWith('.zip') || fileName.endsWith('.rar')) {
      fileIcon = Icons.folder_zip;
    } else if (fileName.endsWith('.txt')) {
      fileIcon = Icons.description;
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _openFile,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(25), // 0.1 * 255
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isMe ? Colors.black26 : Colors.white24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isMe ? Colors.black12 : Colors.white10,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(fileIcon, color: isMe ? Colors.black87 : Colors.white70, size: 32),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fileName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isMe ? Colors.black : Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            fileSize,
                            style: TextStyle(
                              fontSize: 12,
                              color: isMe ? Colors.black54 : Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (message.content.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  message.content,
                  style: TextStyle(
                    color: isMe ? Colors.black : Colors.white,
                  ),
                ),
              ),
            const SizedBox(height: 4),
            Row(
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
          ],
        ),
      ),
    );
  }
}

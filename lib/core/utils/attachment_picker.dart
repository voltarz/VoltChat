import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class AttachmentResult {
  final File file;
  final String originalName;
  final int size;
  final String type; // 'image', 'video', 'file', 'audio'

  AttachmentResult({
    required this.file,
    required this.originalName,
    required this.size,
    required this.type,
  });
}

class AttachmentPicker {
  static final ImagePicker _picker = ImagePicker();

  static Future<AttachmentResult?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return null;

      final file = File(image.path);
      return AttachmentResult(
        file: file,
        originalName: image.name,
        size: await file.length(),
        type: 'image',
      );
    } catch (e) {
      return null;
    }
  }

  static Future<AttachmentResult?> takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo == null) return null;

      final file = File(photo.path);
      return AttachmentResult(
        file: file,
        originalName: photo.name,
        size: await file.length(),
        type: 'image',
      );
    } catch (e) {
      return null;
    }
  }

  static Future<AttachmentResult?> pickVideoFromGallery() async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video == null) return null;

      final file = File(video.path);
      return AttachmentResult(
        file: file,
        originalName: video.name,
        size: await file.length(),
        type: 'video',
      );
    } catch (e) {
      return null;
    }
  }

  static Future<AttachmentResult?> recordVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.camera);
      if (video == null) return null;

      final file = File(video.path);
      return AttachmentResult(
        file: file,
        originalName: video.name,
        size: await file.length(),
        type: 'video',
      );
    } catch (e) {
      return null;
    }
  }

  static Future<AttachmentResult?> pickFile() async {
    try {
      final List<PlatformFile> result = await FilePicker.pickFiles();
      if (result.isNotEmpty && result.single.path != null) {
        final file = File(result.single.path!);
        return AttachmentResult(
          file: file,
          originalName: result.single.name,
          size: await file.length(),
          type: 'file',
        );
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}

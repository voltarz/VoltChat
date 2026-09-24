import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class LocalMediaStorageService {
  LocalMediaStorageService._privateConstructor();
  static final LocalMediaStorageService _instance = LocalMediaStorageService._privateConstructor();
  factory LocalMediaStorageService() => _instance;

  final _uuid = const Uuid();

  Future<String> _getAppDir() async {
    final directory = await getApplicationDocumentsDirectory();
    final mediaDir = Directory('${directory.path}/voltchat_media');
    if (!await mediaDir.exists()) {
      await mediaDir.create(recursive: true);
    }
    return mediaDir.path;
  }

  String _sanitizeFileName(String fileName) {
    return fileName.replaceAll(RegExp(r'[^a-zA-Z0-9.\-_]'), '_');
  }

  Future<String> saveMediaFile(File originalFile, String originalName) async {
    final appDir = await _getAppDir();
    final ext = originalName.contains('.') ? originalName.substring(originalName.lastIndexOf('.')) : '';
    final sanitizedName = _sanitizeFileName(originalName.replaceAll(ext, ''));
    final uniqueName = '${_uuid.v4()}_$sanitizedName$ext';

    final newPath = '$appDir/$uniqueName';
    await originalFile.copy(newPath);
    return newPath;
  }

  Future<String> getMediaPath(String fileName) async {
    final appDir = await _getAppDir();
    return '$appDir/$fileName';
  }

  Future<bool> fileExists(String localPath) async {
    if (localPath.isEmpty) return false;
    final file = File(localPath);
    return await file.exists();
  }

  Future<void> deleteMediaFile(String localPath) async {
    if (localPath.isEmpty) return;
    final file = File(localPath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}

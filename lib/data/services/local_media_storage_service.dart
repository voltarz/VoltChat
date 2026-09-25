import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class LocalMediaStorageService {
  LocalMediaStorageService._privateConstructor();
  static final LocalMediaStorageService _instance = LocalMediaStorageService._privateConstructor();
  factory LocalMediaStorageService() => _instance;

  final _uuid = const Uuid();
  String? _cachedMediaDirPath;

  Future<void> init() async {
    if (_cachedMediaDirPath != null) return;
    final directory = await getApplicationDocumentsDirectory();
    final mediaDir = Directory('${directory.path}/voltchat_media');
    if (!await mediaDir.exists()) {
      await mediaDir.create(recursive: true);
    }
    _cachedMediaDirPath = mediaDir.path;
  }

  Future<String> _getAppDir() async {
    if (_cachedMediaDirPath == null) {
      await init();
    }
    return _cachedMediaDirPath!;
  }

  String? getResolvedPath(String? absolutePath) {
    if (absolutePath == null || absolutePath.isEmpty) return null;
    if (_cachedMediaDirPath == null) return absolutePath; // Fallback, shouldn't happen if initialized

    final uri = Uri.file(absolutePath);
    final fileName = uri.pathSegments.last;

    // We construct the path manually to support both formats.
    return '$_cachedMediaDirPath/$fileName';
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
    final resolvedPath = getResolvedPath(localPath) ?? localPath;
    final file = File(resolvedPath);
    return await file.exists();
  }

  Future<void> deleteMediaFile(String localPath) async {
    if (localPath.isEmpty) return;
    final resolvedPath = getResolvedPath(localPath) ?? localPath;
    final file = File(resolvedPath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}

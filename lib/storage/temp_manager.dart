import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:ftp_photo_server/core/constants.dart';

/// Manages temporary files for image processing
class TempManager {
  TempManager._();

  /// Save bytes to temporary file
  static Future<String> saveToTemp(Uint8List bytes, String filename) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  /// Get temporary directory path
  static Future<String> getTempDirPath() async {
    final dir = await getTemporaryDirectory();
    return dir.path;
  }

  /// Clean up temporary files older than specified hours
  static Future<void> cleanOldTempFiles({int olderThanHours = 1}) async {
    final dir = await getTemporaryDirectory();
    final now = DateTime.now();
    
    if (await dir.exists()) {
      final files = await dir.list().toList();
      for (var entity in files) {
        if (entity is File) {
          final stat = await entity.stat();
          final age = now.difference(stat.modified);
          
          if (age.inHours >= olderThanHours) {
            try {
              await entity.delete();
            } catch (e) {
              // Silently ignore errors during cleanup
            }
          }
        }
      }
    }
  }

  /// Validate file extension
  static bool isValidImageExtension(String filename) {
    final ext = _getFileExtension(filename).toLowerCase();
    return AppConstants.supportedImageExtensions.contains(ext);
  }

  /// Get file extension
  static String _getFileExtension(String filename) {
    final lastDotIndex = filename.lastIndexOf('.');
    if (lastDotIndex != -1) {
      return filename.substring(lastDotIndex);
    }
    return '';
  }

  /// Validate file size
  static bool isValidFileSize(int fileSize) {
    return fileSize <= AppConstants.maxFileSize;
  }

  /// Get file size in bytes
  static Future<int> getFileSize(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      final stat = await file.stat();
      return stat.size;
    }
    return 0;
  }

  /// Delete temporary file
  static Future<void> deleteTempFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      try {
        await file.delete();
      } catch (e) {
        // Silently ignore errors during deletion
      }
    }
  }
}

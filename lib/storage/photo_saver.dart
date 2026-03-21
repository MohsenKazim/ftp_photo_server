import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:ftp_photo_server/core/app_state.dart';

/// Saves received images to Camera Roll
class PhotoSaver {
  PhotoSaver._();

  /// Save image bytes to Camera Roll
  static Future<String?> saveImageToGallery(
    Uint8List bytes, {
    String? filename,
    AppState? appState,
  }) async {
    try {
      // Verify it's a valid image
      if (!_isValidImage(bytes)) {
        throw Exception('Invalid image data');
      }

      // Determine file extension
      final ext = _getImageExtension(bytes);
      final name = filename ?? 'image_${DateTime.now().millisecondsSinceEpoch}$ext';

      // Save to photo library using photo_manager 3.x API
      // photo_manager 3.x requires filename parameter
      await PhotoManager.editor.saveImage(
        bytes,
        filename: name,
      );

      // Update app state if provided
      if (appState != null) {
        final imageInfo = ReceivedImageInfo(
          filename: name,
          receivedAt: DateTime.now(),
          sizeBytes: bytes.length,
          path: null, // photo_manager 3.x doesn't provide path directly
        );
        appState.addReceivedImage(imageInfo);
      }

      return 'Camera Roll';
    } catch (e) {
      // Fallback to file save if photo_manager fails
      final path = await _saveToFile(bytes, filename);

      // Update app state if provided
      if (appState != null) {
        final imageInfo = ReceivedImageInfo(
          filename: filename ?? 'image_${DateTime.now().millisecondsSinceEpoch}.jpg',
          receivedAt: DateTime.now(),
          sizeBytes: bytes.length,
          path: path,
        );
        appState.addReceivedImage(imageInfo);
      }

      return path;
    }
  }

  /// Check if bytes represent a valid image
  static bool _isValidImage(Uint8List bytes) {
    if (bytes.length < 12) return false;
    
    // Check for common image signatures
    final signature = bytes.sublist(0, 12);
    
    // JPEG: FF D8 FF
    if (signature[0] == 0xFF && signature[1] == 0xD8 && signature[2] == 0xFF) {
      return true;
    }
    
    // PNG: 89 50 4E 47
    if (signature[0] == 0x89 && 
        signature[1] == 0x50 && 
        signature[2] == 0x4E && 
        signature[3] == 0x47) {
      return true;
    }
    
    // GIF: 47 49 46 38
    if (signature[0] == 0x47 && 
        signature[1] == 0x49 && 
        signature[2] == 0x46 && 
        signature[3] == 0x38) {
      return true;
    }
    
    // BMP: 42 4D
    if (signature[0] == 0x42 && signature[1] == 0x4D) {
      return true;
    }

    // HEIC: ftyp (usually at offset 4)
    // Common heic types: ftypheic, ftypheix, ftyphevc
    if (signature[4] == 0x66 && signature[5] == 0x74 && 
        signature[6] == 0x79 && signature[7] == 0x70) {
        return true;
    }
    
    return false;
  }

  /// Get file extension from image signature
  static String _getImageExtension(Uint8List bytes) {
    if (bytes.length < 12) return '.jpg';
    
    final signature = bytes.sublist(0, 12);
    
    if (signature[0] == 0xFF && signature[1] == 0xD8 && signature[2] == 0xFF) {
      return '.jpg';
    }
    if (signature[0] == 0x89 && 
        signature[1] == 0x50 && 
        signature[2] == 0x4E && 
        signature[3] == 0x47) {
      return '.png';
    }
    if (signature[0] == 0x47 && 
        signature[1] == 0x49 && 
        signature[2] == 0x46 && 
        signature[3] == 0x38) {
      return '.gif';
    }
    if (signature[0] == 0x42 && signature[1] == 0x4D) {
      return '.bmp';
    }
    // HEIC check
    if (signature[4] == 0x66 && signature[5] == 0x74 && 
        signature[6] == 0x79 && signature[7] == 0x70) {
      return '.heic';
    }
    
    // Default to JPEG
    return '.jpg';
  }

  /// Fallback: Save to file
  static Future<String> _saveToFile(Uint8List bytes, String? filename) async {
    final dir = await getApplicationDocumentsDirectory();
    final name = filename ?? 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(bytes);
    return file.path;
  }
}

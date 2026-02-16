import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class ImageCompressionService {
  static const int maxFileSizeBytes = 5 * 1024 * 1024; // 5MB
  static const int thumbnailSize = 300;
  static const int compressedImageMaxWidth = 1920;
  static const int compressedImageMaxHeight = 1080;
  static const int quality = 85;

  /// Validate file size
  static Future<bool> validateFileSize(File file) async {
    final fileSize = await file.length();
    return fileSize <= maxFileSizeBytes;
  }

  /// Validate file format
  static bool validateFileFormat(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png', 'webp'].contains(extension);
  }

  /// Compress image for upload
  static Future<File?> compressImage(File file) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
        minWidth: compressedImageMaxWidth,
        minHeight: compressedImageMaxHeight,
        format: CompressFormat.jpeg,
      );

      if (result == null) return null;
      return File(result.path);
    } catch (e) {
      print('Error compressing image: $e');
      return null;
    }
  }

  /// Generate thumbnail
  static Future<File?> generateThumbnail(File file) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/thumb_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 70,
        minWidth: thumbnailSize,
        minHeight: thumbnailSize,
        format: CompressFormat.jpeg,
      );

      if (result == null) return null;
      return File(result.path);
    } catch (e) {
      print('Error generating thumbnail: $e');
      return null;
    }
  }

  /// Compress to bytes for preview
  static Future<Uint8List?> compressToBytes(File file, int maxWidth) async {
    try {
      return await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        quality: quality,
        minWidth: maxWidth,
        format: CompressFormat.jpeg,
      );
    } catch (e) {
      print('Error compressing to bytes: $e');
      return null;
    }
  }
}

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../utils/image_compression.dart';

class PhotoUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _uuid = Uuid();

  /// Upload photo and thumbnail to Firebase Storage
  /// Returns a map with 'imageUrl' and 'thumbnailUrl'
  Future<Map<String, String>> uploadPhoto({
    required File imageFile,
    required String userId,
  }) async {
    try {
      // Validate file size
      final isValidSize = await ImageCompressionService.validateFileSize(imageFile);
      if (!isValidSize) {
        throw Exception('File size exceeds 5MB limit');
      }

      // Validate file format
      final isValidFormat = ImageCompressionService.validateFileFormat(imageFile.path);
      if (!isValidFormat) {
        throw Exception('Unsupported file format. Use JPG, PNG, or WebP');
      }

      // Compress main image
      final compressedImage = await ImageCompressionService.compressImage(imageFile);
      if (compressedImage == null) {
        throw Exception('Failed to compress image');
      }

      // Generate thumbnail
      final thumbnail = await ImageCompressionService.generateThumbnail(imageFile);
      if (thumbnail == null) {
        throw Exception('Failed to generate thumbnail');
      }

      // Generate unique filename
      final imageId = _uuid.v4();
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // Upload main image
      final imageRef = _storage.ref().child('memories/$userId/$timestamp-$imageId.jpg');
      final imageUploadTask = await imageRef.putFile(compressedImage);
      final imageUrl = await imageUploadTask.ref.getDownloadURL();

      // Upload thumbnail
      final thumbRef = _storage.ref().child('memories/$userId/thumbnails/$timestamp-$imageId-thumb.jpg');
      final thumbUploadTask = await thumbRef.putFile(thumbnail);
      final thumbnailUrl = await thumbUploadTask.ref.getDownloadURL();

      // Clean up temporary files
      await compressedImage.delete();
      await thumbnail.delete();

      return {
        'imageUrl': imageUrl,
        'thumbnailUrl': thumbnailUrl,
      };
    } catch (e) {
      throw Exception('Photo upload failed: $e');
    }
  }

  /// Delete photo and thumbnail from Firebase Storage
  Future<void> deletePhoto(String imageUrl, String? thumbnailUrl) async {
    try {
      // Delete main image
      final imageRef = _storage.refFromURL(imageUrl);
      await imageRef.delete();

      // Delete thumbnail if exists
      if (thumbnailUrl != null && thumbnailUrl.isNotEmpty) {
        final thumbRef = _storage.refFromURL(thumbnailUrl);
        await thumbRef.delete();
      }
    } catch (e) {
      print('Error deleting photo: $e');
      // Don't throw, just log the error
    }
  }

  /// Get signed URL for secure access (already handled by Firebase Storage)
  Future<String> getSignedUrl(String path) async {
    try {
      final ref = _storage.ref(path);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to get signed URL: $e');
    }
  }
}

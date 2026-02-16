import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/memory.dart';
import 'photo_upload_service.dart';

class MemoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PhotoUploadService _photoUploadService = PhotoUploadService();

  /// Create new memory with photo upload
  Future<MemoryModel> createMemory({
    required String userId,
    required File imageFile,
    required String caption,
    required double latitude,
    required double longitude,
    required MemoryVisibility visibility,
    String? rideId,
    List<String> tags = const [],
  }) async {
    try {
      // Upload photo
      final uploadResult = await _photoUploadService.uploadPhoto(
        imageFile: imageFile,
        userId: userId,
      );

      // Create memory document
      final memoryRef = _firestore.collection('memories').doc();
      final memory = MemoryModel(
        memoryId: memoryRef.id,
        userId: userId,
        imageUrl: uploadResult['imageUrl']!,
        thumbnailUrl: uploadResult['thumbnailUrl'],
        caption: caption,
        latitude: latitude,
        longitude: longitude,
        createdAt: DateTime.now(),
        visibility: visibility,
        rideId: rideId,
        tags: tags,
      );

      await memoryRef.set(memory.toFirestore());
      return memory;
    } catch (e) {
      throw Exception('Failed to create memory: $e');
    }
  }

  /// Get user's memories with privacy filters
  Future<List<MemoryModel>> getUserMemories({
    required String userId,
    required String currentUserId,
    bool publicOnly = false,
  }) async {
    try {
      Query query = _firestore.collection('memories').where('userId', isEqualTo: userId);

      // Apply privacy filter
      if (publicOnly || userId != currentUserId) {
        query = query.where('visibility', isEqualTo: 'public');
      }

      final snapshot = await query.orderBy('createdAt', descending: true).get();
      return snapshot.docs.map((doc) => MemoryModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch memories: $e');
    }
  }

  /// Get public memories only
  Future<List<MemoryModel>> getPublicMemories({int limit = 50}) async {
    try {
      final snapshot = await _firestore
          .collection('memories')
          .where('visibility', isEqualTo: 'public')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => MemoryModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch public memories: $e');
    }
  }

  /// Get memories from friends (feed)
  Future<List<MemoryModel>> getFriendsMemories({
    required String currentUserId,
    required List<String> friendIds,
    int limit = 50,
  }) async {
    try {
      if (friendIds.isEmpty) return [];

      final snapshot = await _firestore
          .collection('memories')
          .where('userId', whereIn: friendIds)
          .where('visibility', whereIn: ['public', 'friends'])
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => MemoryModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch friends memories: $e');
    }
  }

  /// Update memory (caption, visibility)
  Future<void> updateMemory({
    required String memoryId,
    String? caption,
    MemoryVisibility? visibility,
    List<String>? tags,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (caption != null) updates['caption'] = caption;
      if (visibility != null) updates['visibility'] = visibility.name;
      if (tags != null) updates['tags'] = tags;

      await _firestore.collection('memories').doc(memoryId).update(updates);
    } catch (e) {
      throw Exception('Failed to update memory: $e');
    }
  }

  /// Delete memory
  Future<void> deleteMemory(String memoryId) async {
    try {
      // Get memory to delete associated photos
      final doc = await _firestore.collection('memories').doc(memoryId).get();
      if (doc.exists) {
        final memory = MemoryModel.fromFirestore(doc);
        
        // Delete photos from storage
        await _photoUploadService.deletePhoto(memory.imageUrl, memory.thumbnailUrl);
        
        // Delete memory document
        await doc.reference.delete();

        // Delete associated interactions
        final interactions = await _firestore
            .collection('memory_interactions')
            .where('memoryId', isEqualTo: memoryId)
            .get();
        
        for (var interaction in interactions.docs) {
          await interaction.reference.delete();
        }
      }
    } catch (e) {
      throw Exception('Failed to delete memory: $e');
    }
  }

  /// Increment view count
  Future<void> recordView({
    required String memoryId,
    required String userId,
  }) async {
    try {
      // Record interaction
      await _firestore.collection('memory_interactions').add(
        MemoryInteraction(
          userId: userId,
          memoryId: memoryId,
          action: 'view',
          timestamp: DateTime.now(),
        ).toFirestore(),
      );

      // Increment view count
      await _firestore.collection('memories').doc(memoryId).update({
        'viewCount': FieldValue.increment(1),
      });
    } catch (e) {
      print('Failed to record view: $e');
    }
  }

  /// Toggle like
  Future<bool> toggleLike({
    required String memoryId,
    required String userId,
  }) async {
    try {
      // Check if already liked
      final existing = await _firestore
          .collection('memory_interactions')
          .where('memoryId', isEqualTo: memoryId)
          .where('userId', isEqualTo: userId)
          .where('action', isEqualTo: 'like')
          .get();

      if (existing.docs.isNotEmpty) {
        // Unlike
        for (var doc in existing.docs) {
          await doc.reference.delete();
        }
        await _firestore.collection('memories').doc(memoryId).update({
          'likeCount': FieldValue.increment(-1),
        });
        return false;
      } else {
        // Like
        await _firestore.collection('memory_interactions').add(
          MemoryInteraction(
            userId: userId,
            memoryId: memoryId,
            action: 'like',
            timestamp: DateTime.now(),
          ).toFirestore(),
        );
        await _firestore.collection('memories').doc(memoryId).update({
          'likeCount': FieldValue.increment(1),
        });
        return true;
      }
    } catch (e) {
      throw Exception('Failed to toggle like: $e');
    }
  }

  /// Check if user has liked a memory
  Future<bool> hasLiked({
    required String memoryId,
    required String userId,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('memory_interactions')
          .where('memoryId', isEqualTo: memoryId)
          .where('userId', isEqualTo: userId)
          .where('action', isEqualTo: 'like')
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get memories by date range
  Future<List<MemoryModel>> getMemoriesByDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('memories')
          .where('userId', isEqualTo: userId)
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => MemoryModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch memories by date: $e');
    }
  }

  /// Search memories by caption or tags
  Future<List<MemoryModel>> searchMemories({
    required String userId,
    required String query,
  }) async {
    try {
      // Note: Firestore doesn't support full-text search natively
      // This is a basic implementation that filters on the client side
      final snapshot = await _firestore
          .collection('memories')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      final memories = snapshot.docs.map((doc) => MemoryModel.fromFirestore(doc)).toList();
      
      final lowerQuery = query.toLowerCase();
      return memories.where((memory) {
        return memory.caption.toLowerCase().contains(lowerQuery) ||
               memory.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
      }).toList();
    } catch (e) {
      throw Exception('Failed to search memories: $e');
    }
  }
}

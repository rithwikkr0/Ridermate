import 'package:flutter_test/flutter_test.dart';
import 'package:ridermate_app/main.dart';

void main() {
  group('Memory Model Tests', () {
    test('should create Memory instance with correct values', () {
      // Arrange
      final name = 'Test Memory';
      final lat = 12.34;
      final lon = 77.56;
      final note = 'Beautiful sunset';
      final privacy = 'public';
      final likes = 50;

      // Act
      final memory = Memory(name, lat, lon, note, privacy, likes);

      // Assert
      expect(memory.name, equals(name));
      expect(memory.lat, equals(lat));
      expect(memory.lon, equals(lon));
      expect(memory.note, equals(note));
      expect(memory.privacy, equals(privacy));
      expect(memory.likes, equals(likes));
    });

    test('should handle different privacy settings', () {
      // Arrange & Act
      final publicMemory = Memory('Public', 0, 0, 'note', 'public', 100);
      final friendsMemory = Memory('Friends', 0, 0, 'note', 'friends', 50);
      final privateMemory = Memory('Private', 0, 0, 'note', 'private', 0);

      // Assert
      expect(publicMemory.privacy, equals('public'));
      expect(friendsMemory.privacy, equals('friends'));
      expect(privateMemory.privacy, equals('private'));
    });

    test('should store GPS coordinates correctly', () {
      // Arrange
      final lat = 12.9716;
      final lon = 77.5946;

      // Act
      final memory = Memory('Bangalore', lat, lon, 'City center', 'public', 0);

      // Assert
      expect(memory.lat, equals(lat));
      expect(memory.lon, equals(lon));
    });

    test('should handle negative coordinates', () {
      // Arrange
      final lat = -33.8688;
      final lon = 151.2093;

      // Act
      final memory = Memory('Sydney', lat, lon, 'Opera House', 'public', 0);

      // Assert
      expect(memory.lat, equals(lat));
      expect(memory.lon, equals(lon));
    });

    test('should handle zero likes for private memories', () {
      // Arrange & Act
      final privateMemory = Memory('Private Spot', 0, 0, 'Secret', 'private', 0);

      // Assert
      expect(privateMemory.likes, equals(0));
      expect(privateMemory.privacy, equals('private'));
    });

    test('should allow different like counts', () {
      // Arrange & Act
      final noLikes = Memory('New', 0, 0, 'note', 'public', 0);
      final someLikes = Memory('Popular', 0, 0, 'note', 'public', 150);
      final manyLikes = Memory('Viral', 0, 0, 'note', 'public', 10000);

      // Assert
      expect(noLikes.likes, equals(0));
      expect(someLikes.likes, equals(150));
      expect(manyLikes.likes, equals(10000));
    });
  });
}

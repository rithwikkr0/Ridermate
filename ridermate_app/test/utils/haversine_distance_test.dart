import 'dart:math';
import 'package:flutter_test/flutter_test.dart';

/// Utility class for calculating distance between two GPS coordinates using the Haversine formula
class HaversineDistance {
  /// Earth's radius in kilometers
  static const double earthRadiusKm = 6371.0;

  /// Calculate the distance between two GPS coordinates in kilometers
  /// 
  /// [lat1] - Latitude of the first point
  /// [lon1] - Longitude of the first point
  /// [lat2] - Latitude of the second point
  /// [lon2] - Longitude of the second point
  /// 
  /// Returns the distance in kilometers
  static double calculate(double lat1, double lon1, double lat2, double lon2) {
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusKm * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }
}

void main() {
  group('HaversineDistance Tests', () {
    test('should calculate distance between two close points', () {
      // Arrange
      final lat1 = 12.9716; // Bangalore
      final lon1 = 77.5946;
      final lat2 = 12.9726; // Very close to Bangalore
      final lon2 = 77.5956;

      // Act
      final distance = HaversineDistance.calculate(lat1, lon1, lat2, lon2);

      // Assert - Should be less than 2 km
      expect(distance, lessThan(2.0));
      expect(distance, greaterThan(0.0));
    });

    test('should return zero for identical coordinates', () {
      // Arrange
      final lat = 12.9716;
      final lon = 77.5946;

      // Act
      final distance = HaversineDistance.calculate(lat, lon, lat, lon);

      // Assert
      expect(distance, equals(0.0));
    });

    test('should calculate distance between Bangalore and Mumbai', () {
      // Arrange
      final bangaloreLat = 12.9716;
      final bangaloreLon = 77.5946;
      final mumbaiLat = 19.0760;
      final mumbaiLon = 72.8777;

      // Act
      final distance = HaversineDistance.calculate(
        bangaloreLat,
        bangaloreLon,
        mumbaiLat,
        mumbaiLon,
      );

      // Assert - Approximate distance is ~840 km
      expect(distance, greaterThan(800.0));
      expect(distance, lessThan(900.0));
    });

    test('should handle negative coordinates', () {
      // Arrange - New York to London
      final nyLat = 40.7128;
      final nyLon = -74.0060;
      final londonLat = 51.5074;
      final londonLon = -0.1278;

      // Act
      final distance = HaversineDistance.calculate(nyLat, nyLon, londonLat, londonLon);

      // Assert - Approximate distance is ~5,570 km
      expect(distance, greaterThan(5400.0));
      expect(distance, lessThan(5700.0));
    });

    test('should handle coordinates across the equator', () {
      // Arrange
      final northLat = 10.0;
      final northLon = 0.0;
      final southLat = -10.0;
      final southLon = 0.0;

      // Act
      final distance = HaversineDistance.calculate(northLat, northLon, southLat, southLon);

      // Assert - Approximately 2,220 km (20 degrees of latitude)
      expect(distance, greaterThan(2200.0));
      expect(distance, lessThan(2300.0));
    });

    test('should be symmetric', () {
      // Arrange
      final lat1 = 12.9716;
      final lon1 = 77.5946;
      final lat2 = 19.0760;
      final lon2 = 72.8777;

      // Act
      final distance1 = HaversineDistance.calculate(lat1, lon1, lat2, lon2);
      final distance2 = HaversineDistance.calculate(lat2, lon2, lat1, lon1);

      // Assert - Distance should be the same regardless of order
      expect(distance1, equals(distance2));
    });

    test('should handle very small distances accurately', () {
      // Arrange - Points 100 meters apart (approximately)
      final lat1 = 0.0;
      final lon1 = 0.0;
      final lat2 = 0.0009; // Approximately 100m
      final lon2 = 0.0;

      // Act
      final distance = HaversineDistance.calculate(lat1, lon1, lat2, lon2);

      // Assert - Should be approximately 0.1 km
      expect(distance, greaterThan(0.09));
      expect(distance, lessThan(0.11));
    });
  });
}

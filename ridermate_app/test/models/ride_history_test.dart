import 'package:flutter_test/flutter_test.dart';
import 'package:ridermate_app/main.dart';

void main() {
  group('RideHistory Model Tests', () {
    test('should create RideHistory instance with correct values', () {
      // Arrange
      final name = 'Test Route';
      final distance = 25.5;
      final duration = 45;
      final date = DateTime(2024, 1, 15);

      // Act
      final rideHistory = RideHistory(name, distance, duration, date);

      // Assert
      expect(rideHistory.name, equals(name));
      expect(rideHistory.distance, equals(distance));
      expect(rideHistory.duration, equals(duration));
      expect(rideHistory.date, equals(date));
    });

    test('should handle different distance values', () {
      // Arrange & Act
      final shortRide = RideHistory('Short', 5.0, 10, DateTime.now());
      final longRide = RideHistory('Long', 100.5, 180, DateTime.now());

      // Assert
      expect(shortRide.distance, equals(5.0));
      expect(longRide.distance, equals(100.5));
    });

    test('should handle zero distance', () {
      // Arrange & Act
      final zeroRide = RideHistory('Zero', 0.0, 0, DateTime.now());

      // Assert
      expect(zeroRide.distance, equals(0.0));
      expect(zeroRide.duration, equals(0));
    });

    test('should store exact DateTime', () {
      // Arrange
      final specificDate = DateTime(2024, 6, 15, 14, 30, 0);

      // Act
      final ride = RideHistory('Timed Ride', 10.0, 20, specificDate);

      // Assert
      expect(ride.date.year, equals(2024));
      expect(ride.date.month, equals(6));
      expect(ride.date.day, equals(15));
      expect(ride.date.hour, equals(14));
      expect(ride.date.minute, equals(30));
    });
  });
}

import 'package:flutter_test/flutter_test.dart';

/// Utility class for speed calculations
class SpeedCalculation {
  /// Calculate speed in km/h from distance (km) and time (seconds)
  static double calculateSpeed(double distanceKm, int timeSeconds) {
    if (timeSeconds == 0) {
      return 0.0;
    }
    final timeHours = timeSeconds / 3600.0;
    return distanceKm / timeHours;
  }

  /// Calculate average speed from total distance and total time
  static double calculateAverageSpeed(double totalDistanceKm, int totalTimeSeconds) {
    return calculateSpeed(totalDistanceKm, totalTimeSeconds);
  }

  /// Convert speed from km/h to m/s
  static double kmhToMs(double speedKmh) {
    return speedKmh / 3.6;
  }

  /// Convert speed from m/s to km/h
  static double msToKmh(double speedMs) {
    return speedMs * 3.6;
  }

  /// Calculate calories burned based on speed, distance, and rider weight
  /// Approximate formula for cycling
  static double calculateCalories(double distanceKm, double speedKmh, double weightKg) {
    // MET (Metabolic Equivalent) values for cycling
    double met;
    if (speedKmh < 16) {
      met = 4.0; // Light effort
    } else if (speedKmh < 19) {
      met = 6.8; // Moderate effort
    } else if (speedKmh < 22) {
      met = 8.0; // Vigorous effort
    } else {
      met = 10.0; // Very vigorous effort
    }

    final timeHours = distanceKm / speedKmh;
    return met * weightKg * timeHours;
  }
}

void main() {
  group('SpeedCalculation Tests', () {
    test('should calculate speed correctly', () {
      // Arrange
      final distance = 10.0; // 10 km
      final time = 1800; // 30 minutes in seconds

      // Act
      final speed = SpeedCalculation.calculateSpeed(distance, time);

      // Assert - 10 km in 30 min = 20 km/h
      expect(speed, equals(20.0));
    });

    test('should return zero speed when time is zero', () {
      // Arrange
      final distance = 10.0;
      final time = 0;

      // Act
      final speed = SpeedCalculation.calculateSpeed(distance, time);

      // Assert
      expect(speed, equals(0.0));
    });

    test('should calculate speed for one hour ride', () {
      // Arrange
      final distance = 25.0; // 25 km
      final time = 3600; // 1 hour in seconds

      // Act
      final speed = SpeedCalculation.calculateSpeed(distance, time);

      // Assert
      expect(speed, equals(25.0));
    });

    test('should convert km/h to m/s correctly', () {
      // Arrange
      final speedKmh = 36.0; // 36 km/h

      // Act
      final speedMs = SpeedCalculation.kmhToMs(speedKmh);

      // Assert - 36 km/h = 10 m/s
      expect(speedMs, equals(10.0));
    });

    test('should convert m/s to km/h correctly', () {
      // Arrange
      final speedMs = 10.0; // 10 m/s

      // Act
      final speedKmh = SpeedCalculation.msToKmh(speedMs);

      // Assert - 10 m/s = 36 km/h
      expect(speedKmh, equals(36.0));
    });

    test('should calculate average speed correctly', () {
      // Arrange
      final totalDistance = 50.0; // 50 km
      final totalTime = 7200; // 2 hours in seconds

      // Act
      final avgSpeed = SpeedCalculation.calculateAverageSpeed(totalDistance, totalTime);

      // Assert - 50 km in 2 hours = 25 km/h
      expect(avgSpeed, equals(25.0));
    });

    test('should calculate calories for light effort cycling', () {
      // Arrange
      final distance = 10.0; // 10 km
      final speed = 15.0; // 15 km/h (light effort)
      final weight = 70.0; // 70 kg

      // Act
      final calories = SpeedCalculation.calculateCalories(distance, speed, weight);

      // Assert - Should be approximately 186 kcal (4 MET * 70 kg * 0.67 hours)
      expect(calories, greaterThan(180.0));
      expect(calories, lessThan(190.0));
    });

    test('should calculate calories for vigorous effort cycling', () {
      // Arrange
      final distance = 20.0; // 20 km
      final speed = 20.0; // 20 km/h (vigorous effort)
      final weight = 70.0; // 70 kg

      // Act
      final calories = SpeedCalculation.calculateCalories(distance, speed, weight);

      // Assert - Should be approximately 560 kcal (8 MET * 70 kg * 1 hour)
      expect(calories, greaterThan(540.0));
      expect(calories, lessThan(580.0));
    });

    test('should handle fractional distances', () {
      // Arrange
      final distance = 5.5; // 5.5 km
      final time = 900; // 15 minutes in seconds

      // Act
      final speed = SpeedCalculation.calculateSpeed(distance, time);

      // Assert - 5.5 km in 15 min = 22 km/h
      expect(speed, equals(22.0));
    });

    test('should handle very high speeds', () {
      // Arrange
      final distance = 100.0; // 100 km
      final time = 3600; // 1 hour

      // Act
      final speed = SpeedCalculation.calculateSpeed(distance, time);

      // Assert
      expect(speed, equals(100.0));
    });
  });
}

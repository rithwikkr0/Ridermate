import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

/// Utility class for date and time formatting
class DateFormatting {
  /// Format DateTime to a readable date string (e.g., "Jan 15, 2024")
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  /// Format DateTime to time string (e.g., "14:30")
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  /// Format DateTime to full date and time (e.g., "Jan 15, 2024 14:30")
  static String formatDateTime(DateTime date) {
    return DateFormat('MMM dd, yyyy HH:mm').format(date);
  }

  /// Format duration in seconds to readable string (e.g., "1h 30m")
  static String formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      if (minutes > 0) {
        return '${hours}h ${minutes}m';
      }
      return '${hours}h';
    } else if (minutes > 0) {
      if (secs > 0) {
        return '${minutes}m ${secs}s';
      }
      return '${minutes}m';
    } else {
      return '${secs}s';
    }
  }

  /// Format duration in HH:MM:SS format
  static String formatDurationHMS(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// Get relative time string (e.g., "2 days ago", "Just now")
  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? '1 year ago' : '$years years ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    } else if (difference.inDays > 0) {
      return difference.inDays == 1
          ? '1 day ago'
          : '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return difference.inHours == 1
          ? '1 hour ago'
          : '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return difference.inMinutes == 1
          ? '1 minute ago'
          : '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }
}

void main() {
  group('DateFormatting Tests', () {
    test('should format date correctly', () {
      // Arrange
      final date = DateTime(2024, 1, 15);

      // Act
      final formatted = DateFormatting.formatDate(date);

      // Assert
      expect(formatted, equals('Jan 15, 2024'));
    });

    test('should format time correctly', () {
      // Arrange
      final date = DateTime(2024, 1, 15, 14, 30);

      // Act
      final formatted = DateFormatting.formatTime(date);

      // Assert
      expect(formatted, equals('14:30'));
    });

    test('should format DateTime correctly', () {
      // Arrange
      final date = DateTime(2024, 1, 15, 14, 30);

      // Act
      final formatted = DateFormatting.formatDateTime(date);

      // Assert
      expect(formatted, equals('Jan 15, 2024 14:30'));
    });

    test('should format duration with hours and minutes', () {
      // Arrange
      final seconds = 5400; // 1 hour 30 minutes

      // Act
      final formatted = DateFormatting.formatDuration(seconds);

      // Assert
      expect(formatted, equals('1h 30m'));
    });

    test('should format duration with only minutes', () {
      // Arrange
      final seconds = 600; // 10 minutes

      // Act
      final formatted = DateFormatting.formatDuration(seconds);

      // Assert
      expect(formatted, equals('10m'));
    });

    test('should format duration with only seconds', () {
      // Arrange
      final seconds = 45; // 45 seconds

      // Act
      final formatted = DateFormatting.formatDuration(seconds);

      // Assert
      expect(formatted, equals('45s'));
    });

    test('should format duration in HH:MM:SS format', () {
      // Arrange
      final seconds = 3661; // 1 hour, 1 minute, 1 second

      // Act
      final formatted = DateFormatting.formatDurationHMS(seconds);

      // Assert
      expect(formatted, equals('01:01:01'));
    });

    test('should format short duration in HH:MM:SS format', () {
      // Arrange
      final seconds = 125; // 2 minutes, 5 seconds

      // Act
      final formatted = DateFormatting.formatDurationHMS(seconds);

      // Assert
      expect(formatted, equals('00:02:05'));
    });

    test('should identify today correctly', () {
      // Arrange
      final today = DateTime.now();

      // Act
      final result = DateFormatting.isToday(today);

      // Assert
      expect(result, isTrue);
    });

    test('should identify yesterday correctly', () {
      // Arrange
      final yesterday = DateTime.now().subtract(Duration(days: 1));

      // Act
      final result = DateFormatting.isYesterday(yesterday);

      // Assert
      expect(result, isTrue);
    });

    test('should not identify old date as today', () {
      // Arrange
      final oldDate = DateTime(2020, 1, 1);

      // Act
      final result = DateFormatting.isToday(oldDate);

      // Assert
      expect(result, isFalse);
    });

    test('should handle different months in date formatting', () {
      // Arrange
      final dates = [
        DateTime(2024, 1, 1),
        DateTime(2024, 6, 15),
        DateTime(2024, 12, 31),
      ];

      // Act
      final formatted = dates.map((d) => DateFormatting.formatDate(d)).toList();

      // Assert
      expect(formatted[0], equals('Jan 01, 2024'));
      expect(formatted[1], equals('Jun 15, 2024'));
      expect(formatted[2], equals('Dec 31, 2024'));
    });
  });
}

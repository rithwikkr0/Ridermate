// Unit tests for data models
import 'package:flutter_test/flutter_test.dart';
import 'package:ridermate_app/models/ride_metrics.dart';
import 'package:ridermate_app/models/ai_analysis.dart';
import 'package:ridermate_app/models/chat_message.dart';
import 'package:ridermate_app/models/weekly_analysis.dart';

void main() {
  group('RideMetrics', () {
    test('toJson and fromJson work correctly', () {
      final original = RideMetrics(
        distance: 10.5,
        duration: 1800,
        avgSpeed: 21.0,
        overspeeds: 2,
        maxSpeed: 30.0,
        speedPattern: [20.0, 22.0, 21.0],
        timestamp: DateTime(2024, 1, 1, 12, 0, 0),
      );

      final json = original.toJson();
      final restored = RideMetrics.fromJson(json);

      expect(restored.distance, equals(original.distance));
      expect(restored.duration, equals(original.duration));
      expect(restored.avgSpeed, equals(original.avgSpeed));
      expect(restored.overspeeds, equals(original.overspeeds));
      expect(restored.maxSpeed, equals(original.maxSpeed));
      expect(restored.speedPattern, equals(original.speedPattern));
    });
  });

  group('AIAnalysis', () {
    test('toJson and fromJson work correctly', () {
      final original = AIAnalysis(
        feedback: 'Great ride!',
        suggestions: ['Keep it up', 'Maintain pace'],
        safetyScore: 85.5,
        performanceSummary: 'Excellent performance',
        strengths: ['Consistent speed'],
        improvements: ['Reduce overspeeds'],
        analyzedAt: DateTime(2024, 1, 1, 12, 0, 0),
      );

      final json = original.toJson();
      final restored = AIAnalysis.fromJson(json);

      expect(restored.feedback, equals(original.feedback));
      expect(restored.suggestions, equals(original.suggestions));
      expect(restored.safetyScore, equals(original.safetyScore));
      expect(restored.performanceSummary, equals(original.performanceSummary));
      expect(restored.strengths, equals(original.strengths));
      expect(restored.improvements, equals(original.improvements));
    });
  });

  group('ChatMessage', () {
    test('toJson and fromJson work correctly', () {
      final original = ChatMessage(
        role: 'user',
        content: 'How was my ride?',
        timestamp: DateTime(2024, 1, 1, 12, 0, 0),
      );

      final json = original.toJson();
      final restored = ChatMessage.fromJson(json);

      expect(restored.role, equals(original.role));
      expect(restored.content, equals(original.content));
    });

    test('isUser returns correct value', () {
      final userMessage = ChatMessage(
        role: 'user',
        content: 'Test',
        timestamp: DateTime.now(),
      );

      final assistantMessage = ChatMessage(
        role: 'assistant',
        content: 'Response',
        timestamp: DateTime.now(),
      );

      expect(userMessage.isUser, isTrue);
      expect(userMessage.isAssistant, isFalse);
      expect(assistantMessage.isUser, isFalse);
      expect(assistantMessage.isAssistant, isTrue);
    });
  });

  group('WeeklyAnalysis', () {
    test('toJson and fromJson work correctly', () {
      final original = WeeklyAnalysis(
        totalDistance: 100.5,
        totalRides: 7,
        avgSafetyScore: 82.0,
        totalPoints: 1005,
        summary: 'Great week!',
        trends: {'distance': 'up', 'safety': 'stable'},
        metrics: {'avgPerRide': 14.35},
        weekStart: DateTime(2024, 1, 1),
        weekEnd: DateTime(2024, 1, 7),
        weekOverWeekChange: 5.5,
      );

      final json = original.toJson();
      final restored = WeeklyAnalysis.fromJson(json);

      expect(restored.totalDistance, equals(original.totalDistance));
      expect(restored.totalRides, equals(original.totalRides));
      expect(restored.avgSafetyScore, equals(original.avgSafetyScore));
      expect(restored.totalPoints, equals(original.totalPoints));
      expect(restored.summary, equals(original.summary));
      expect(restored.weekOverWeekChange, equals(original.weekOverWeekChange));
    });
  });
}

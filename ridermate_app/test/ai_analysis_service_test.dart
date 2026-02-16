// Unit tests for AI Analysis Service
import 'package:flutter_test/flutter_test.dart';
import 'package:ridermate_app/models/ride_metrics.dart';
import 'package:ridermate_app/services/ai_analysis_service.dart';

void main() {
  group('AIAnalysisService', () {
    late AIAnalysisService service;

    setUp(() {
      service = AIAnalysisService();
    });

    test('calculateSafetyScore returns score between 0 and 100', () {
      final metrics = RideMetrics(
        distance: 10.0,
        duration: 1800, // 30 minutes
        avgSpeed: 20.0,
        overspeeds: 0,
        maxSpeed: 25.0,
        speedPattern: [18, 19, 20, 21, 22, 20, 19, 21, 20, 19],
        timestamp: DateTime.now(),
      );

      final score = service.calculateSafetyScore(metrics);

      expect(score, greaterThanOrEqualTo(0));
      expect(score, lessThanOrEqualTo(100));
    });

    test('calculateSafetyScore penalizes overspeeds', () {
      final goodRide = RideMetrics(
        distance: 10.0,
        duration: 1800,
        avgSpeed: 20.0,
        overspeeds: 0,
        maxSpeed: 25.0,
        speedPattern: [20, 20, 20, 20, 20],
        timestamp: DateTime.now(),
      );

      final badRide = RideMetrics(
        distance: 10.0,
        duration: 1800,
        avgSpeed: 20.0,
        overspeeds: 5,
        maxSpeed: 25.0,
        speedPattern: [20, 20, 20, 20, 20],
        timestamp: DateTime.now(),
      );

      final goodScore = service.calculateSafetyScore(goodRide);
      final badScore = service.calculateSafetyScore(badRide);

      expect(goodScore, greaterThan(badScore));
    });

    test('calculateSafetyScore rewards consistency', () {
      final consistentRide = RideMetrics(
        distance: 10.0,
        duration: 1800,
        avgSpeed: 20.0,
        overspeeds: 0,
        maxSpeed: 22.0,
        speedPattern: [20, 20, 20, 20, 20, 20, 20, 20],
        timestamp: DateTime.now(),
      );

      final inconsistentRide = RideMetrics(
        distance: 10.0,
        duration: 1800,
        avgSpeed: 20.0,
        overspeeds: 0,
        maxSpeed: 40.0,
        speedPattern: [10, 30, 15, 35, 10, 40, 15, 30],
        timestamp: DateTime.now(),
      );

      final consistentScore = service.calculateSafetyScore(consistentRide);
      final inconsistentScore = service.calculateSafetyScore(inconsistentRide);

      expect(consistentScore, greaterThan(inconsistentScore));
    });

    test('analyzeRide returns valid AIAnalysis', () async {
      final metrics = RideMetrics(
        distance: 15.0,
        duration: 2700,
        avgSpeed: 20.0,
        overspeeds: 1,
        maxSpeed: 28.0,
        speedPattern: [18, 20, 22, 19, 21, 20, 19, 23],
        timestamp: DateTime.now(),
      );

      final analysis = await service.analyzeRide(metrics);

      expect(analysis.safetyScore, greaterThanOrEqualTo(0));
      expect(analysis.safetyScore, lessThanOrEqualTo(100));
      expect(analysis.feedback, isNotEmpty);
      expect(analysis.performanceSummary, isNotEmpty);
    });

    test('generateWeeklyAnalysis handles empty ride list', () async {
      final analysis = await service.generateWeeklyAnalysis([]);

      expect(analysis.totalRides, equals(0));
      expect(analysis.totalDistance, equals(0));
      expect(analysis.summary, contains('No rides'));
    });

    test('generateWeeklyAnalysis calculates correct totals', () async {
      final rides = [
        RideMetrics(
          distance: 10.0,
          duration: 1800,
          avgSpeed: 20.0,
          overspeeds: 0,
          maxSpeed: 25.0,
          speedPattern: [20],
          timestamp: DateTime.now(),
        ),
        RideMetrics(
          distance: 15.0,
          duration: 2700,
          avgSpeed: 20.0,
          overspeeds: 1,
          maxSpeed: 28.0,
          speedPattern: [20],
          timestamp: DateTime.now(),
        ),
      ];

      final analysis = await service.generateWeeklyAnalysis(rides);

      expect(analysis.totalRides, equals(2));
      expect(analysis.totalDistance, equals(25.0));
      expect(analysis.totalPoints, equals(250));
    });
  });
}

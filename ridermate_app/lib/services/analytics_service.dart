import '../models/ride.dart';
import '../models/analytics_data.dart';
import 'package:intl/intl.dart';

class AnalyticsService {
  AnalyticsData calculateAnalytics(List<Ride> rides, String period) {
    final now = DateTime.now();
    DateTime cutoffDate;

    switch (period) {
      case '7days':
        cutoffDate = now.subtract(Duration(days: 7));
        break;
      case '30days':
        cutoffDate = now.subtract(Duration(days: 30));
        break;
      case '90days':
        cutoffDate = now.subtract(Duration(days: 90));
        break;
      case '1year':
        cutoffDate = now.subtract(Duration(days: 365));
        break;
      case 'all-time':
      default:
        cutoffDate = DateTime(2000);
        break;
    }

    final periodRides = rides
        .where((r) => r.startTime.isAfter(cutoffDate))
        .toList();

    if (periodRides.isEmpty) {
      return AnalyticsData.empty(period);
    }

    final ridesInPeriod = periodRides.length;
    final distanceInPeriod = periodRides.fold<double>(0, (sum, r) => sum + r.distance);
    final timeInPeriod = periodRides.fold<int>(0, (sum, r) => sum + r.duration);
    final avgSpeedInPeriod = periodRides.fold<double>(0, (sum, r) => sum + r.avgSpeed) / ridesInPeriod;
    final avgSafetyScoreInPeriod = periodRides.fold<double>(0, (sum, r) => sum + r.safetyScore) / ridesInPeriod;

    // Calculate improvement vs previous period
    final previousCutoffDate = _getPreviousPeriodCutoff(period, cutoffDate);
    final previousRides = rides
        .where((r) =>
            r.startTime.isAfter(previousCutoffDate) &&
            r.startTime.isBefore(cutoffDate))
        .toList();

    final previousDistance = previousRides.isEmpty
        ? 0.0
        : previousRides.fold<double>(0, (sum, r) => sum + r.distance);
    final improvementVsPrevious = previousDistance > 0
        ? ((distanceInPeriod - previousDistance) / previousDistance) * 100
        : 0.0;

    // Calculate weekly/daily trends
    final ridesPerWeek = _calculateRidesPerWeek(periodRides);
    final distancePerWeek = _calculateDistancePerWeek(periodRides);
    final safetyScoreTrend = _calculateSafetyScoreTrend(periodRides);

    // Calculate distributions
    final dayOfWeekDistribution = _calculateDayOfWeekDistribution(periodRides);
    final timeOfDayDistribution = _calculateTimeOfDayDistribution(periodRides);
    final terrainDistribution = _calculateTerrainDistribution(periodRides);

    return AnalyticsData(
      period: period,
      ridesInPeriod: ridesInPeriod,
      distanceInPeriod: distanceInPeriod,
      timeInPeriod: timeInPeriod,
      avgSpeedInPeriod: avgSpeedInPeriod,
      avgSafetyScoreInPeriod: avgSafetyScoreInPeriod,
      improvementVsPrevious: improvementVsPrevious,
      ridesPerWeek: ridesPerWeek,
      distancePerWeek: distancePerWeek,
      safetyScoreTrend: safetyScoreTrend,
      dayOfWeekDistribution: dayOfWeekDistribution,
      timeOfDayDistribution: timeOfDayDistribution,
      terrainDistribution: terrainDistribution,
    );
  }

  DateTime _getPreviousPeriodCutoff(String period, DateTime cutoffDate) {
    switch (period) {
      case '7days':
        return cutoffDate.subtract(Duration(days: 7));
      case '30days':
        return cutoffDate.subtract(Duration(days: 30));
      case '90days':
        return cutoffDate.subtract(Duration(days: 90));
      case '1year':
        return cutoffDate.subtract(Duration(days: 365));
      default:
        return DateTime(2000);
    }
  }

  Map<String, int> _calculateRidesPerWeek(List<Ride> rides) {
    final Map<String, int> ridesPerWeek = {};
    final dateFormat = DateFormat('yyyy-MM-dd');

    for (var ride in rides) {
      final weekStart = _getWeekStart(ride.startTime);
      final key = dateFormat.format(weekStart);
      ridesPerWeek[key] = (ridesPerWeek[key] ?? 0) + 1;
    }

    return ridesPerWeek;
  }

  Map<String, double> _calculateDistancePerWeek(List<Ride> rides) {
    final Map<String, double> distancePerWeek = {};
    final dateFormat = DateFormat('yyyy-MM-dd');

    for (var ride in rides) {
      final weekStart = _getWeekStart(ride.startTime);
      final key = dateFormat.format(weekStart);
      distancePerWeek[key] = (distancePerWeek[key] ?? 0) + ride.distance;
    }

    return distancePerWeek;
  }

  Map<String, double> _calculateSafetyScoreTrend(List<Ride> rides) {
    final Map<String, List<double>> scoresPerWeek = {};
    final dateFormat = DateFormat('yyyy-MM-dd');

    for (var ride in rides) {
      final weekStart = _getWeekStart(ride.startTime);
      final key = dateFormat.format(weekStart);
      scoresPerWeek[key] = (scoresPerWeek[key] ?? [])..add(ride.safetyScore);
    }

    final Map<String, double> avgScoresPerWeek = {};
    scoresPerWeek.forEach((key, scores) {
      final avg = scores.reduce((a, b) => a + b) / scores.length;
      avgScoresPerWeek[key] = avg;
    });

    return avgScoresPerWeek;
  }

  Map<String, int> _calculateDayOfWeekDistribution(List<Ride> rides) {
    final Map<String, int> distribution = {};
    for (var ride in rides) {
      distribution[ride.dayOfWeek] = (distribution[ride.dayOfWeek] ?? 0) + 1;
    }
    return distribution;
  }

  Map<String, int> _calculateTimeOfDayDistribution(List<Ride> rides) {
    final Map<String, int> distribution = {};
    for (var ride in rides) {
      distribution[ride.timeOfDay] = (distribution[ride.timeOfDay] ?? 0) + 1;
    }
    return distribution;
  }

  Map<String, int> _calculateTerrainDistribution(List<Ride> rides) {
    final Map<String, int> distribution = {};
    for (var ride in rides) {
      distribution[ride.terrain] = (distribution[ride.terrain] ?? 0) + 1;
    }
    return distribution;
  }

  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }

  Map<String, dynamic> compareRides(Ride ride1, Ride ride2) {
    return {
      'distance': {
        'ride1': ride1.distance,
        'ride2': ride2.distance,
        'delta': ride1.distance - ride2.distance,
        'deltaPercent': ((ride1.distance - ride2.distance) / ride2.distance) * 100,
      },
      'duration': {
        'ride1': ride1.duration,
        'ride2': ride2.duration,
        'delta': ride1.duration - ride2.duration,
        'deltaPercent': ((ride1.duration - ride2.duration) / ride2.duration) * 100,
      },
      'avgSpeed': {
        'ride1': ride1.avgSpeed,
        'ride2': ride2.avgSpeed,
        'delta': ride1.avgSpeed - ride2.avgSpeed,
        'deltaPercent': ((ride1.avgSpeed - ride2.avgSpeed) / ride2.avgSpeed) * 100,
      },
      'maxSpeed': {
        'ride1': ride1.maxSpeed,
        'ride2': ride2.maxSpeed,
        'delta': ride1.maxSpeed - ride2.maxSpeed,
        'deltaPercent': ((ride1.maxSpeed - ride2.maxSpeed) / ride2.maxSpeed) * 100,
      },
      'safetyScore': {
        'ride1': ride1.safetyScore,
        'ride2': ride2.safetyScore,
        'delta': ride1.safetyScore - ride2.safetyScore,
        'deltaPercent': ((ride1.safetyScore - ride2.safetyScore) / ride2.safetyScore) * 100,
      },
    };
  }

  String getPerformanceTrend(List<Ride> rides, String metric) {
    if (rides.length < 2) return 'insufficient_data';

    final sortedRides = List<Ride>.from(rides)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    final firstHalf = sortedRides.take(sortedRides.length ~/ 2).toList();
    final secondHalf = sortedRides.skip(sortedRides.length ~/ 2).toList();

    double firstAvg, secondAvg;

    switch (metric) {
      case 'distance':
        firstAvg = firstHalf.fold<double>(0, (sum, r) => sum + r.distance) / firstHalf.length;
        secondAvg = secondHalf.fold<double>(0, (sum, r) => sum + r.distance) / secondHalf.length;
        break;
      case 'safety':
        firstAvg = firstHalf.fold<double>(0, (sum, r) => sum + r.safetyScore) / firstHalf.length;
        secondAvg = secondHalf.fold<double>(0, (sum, r) => sum + r.safetyScore) / secondHalf.length;
        break;
      case 'speed':
        firstAvg = firstHalf.fold<double>(0, (sum, r) => sum + r.avgSpeed) / firstHalf.length;
        secondAvg = secondHalf.fold<double>(0, (sum, r) => sum + r.avgSpeed) / secondHalf.length;
        break;
      default:
        return 'unknown_metric';
    }

    final improvement = ((secondAvg - firstAvg) / firstAvg) * 100;

    if (improvement > 10) return 'improving';
    if (improvement < -10) return 'declining';
    return 'stable';
  }
}

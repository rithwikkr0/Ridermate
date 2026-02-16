import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ride.dart';
import '../models/ride_stats.dart';
import '../models/ride_filter.dart';

class RideHistoryService {
  static const String _ridesKey = 'rides_history';
  static const String _statsKey = 'ride_stats_cache';

  Future<List<Ride>> getAllRides() async {
    final prefs = await SharedPreferences.getInstance();
    final ridesJson = prefs.getString(_ridesKey);
    
    if (ridesJson == null) {
      return _generateSampleRides();
    }
    
    final List<dynamic> decoded = json.decode(ridesJson);
    return decoded.map((r) => Ride.fromJson(r)).toList();
  }

  Future<Ride?> getRideById(String rideId) async {
    final rides = await getAllRides();
    try {
      return rides.firstWhere((r) => r.rideId == rideId);
    } catch (e) {
      return null;
    }
  }

  Future<List<Ride>> getUserRides(String userId) async {
    final rides = await getAllRides();
    return rides.where((r) => r.userId == userId).toList();
  }

  Future<void> saveRide(Ride ride) async {
    final rides = await getAllRides();
    rides.add(ride);
    await _saveRides(rides);
  }

  Future<void> deleteRide(String rideId) async {
    final rides = await getAllRides();
    rides.removeWhere((r) => r.rideId == rideId);
    await _saveRides(rides);
  }

  Future<List<Ride>> filterAndSortRides(
    List<Ride> rides,
    RideFilter filter,
    SortOption sortOption,
  ) async {
    var filtered = rides;

    // Apply filters
    if (filter.startDate != null) {
      filtered = filtered
          .where((r) => r.startTime.isAfter(filter.startDate!))
          .toList();
    }

    if (filter.endDate != null) {
      filtered = filtered
          .where((r) => r.startTime.isBefore(filter.endDate!))
          .toList();
    }

    if (filter.minDistance != null) {
      filtered =
          filtered.where((r) => r.distance >= filter.minDistance!).toList();
    }

    if (filter.maxDistance != null) {
      filtered =
          filtered.where((r) => r.distance <= filter.maxDistance!).toList();
    }

    if (filter.minSafetyScore != null) {
      filtered = filtered
          .where((r) => r.safetyScore >= filter.minSafetyScore!)
          .toList();
    }

    if (filter.maxSafetyScore != null) {
      filtered = filtered
          .where((r) => r.safetyScore <= filter.maxSafetyScore!)
          .toList();
    }

    if (filter.minSpeed != null) {
      filtered =
          filtered.where((r) => r.avgSpeed >= filter.minSpeed!).toList();
    }

    if (filter.maxSpeed != null) {
      filtered =
          filtered.where((r) => r.avgSpeed <= filter.maxSpeed!).toList();
    }

    if (filter.timeOfDay != null) {
      filtered =
          filtered.where((r) => r.timeOfDay == filter.timeOfDay).toList();
    }

    if (filter.terrain != null) {
      filtered = filtered.where((r) => r.terrain == filter.terrain).toList();
    }

    if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
      final query = filter.searchQuery!.toLowerCase();
      filtered = filtered.where((r) {
        return r.aiSummary.toLowerCase().contains(query) ||
            r.terrain.toLowerCase().contains(query) ||
            r.dayOfWeek.toLowerCase().contains(query);
      }).toList();
    }

    // Sort
    switch (sortOption) {
      case SortOption.dateNewest:
        filtered.sort((a, b) => b.startTime.compareTo(a.startTime));
        break;
      case SortOption.dateOldest:
        filtered.sort((a, b) => a.startTime.compareTo(b.startTime));
        break;
      case SortOption.distanceLongest:
        filtered.sort((a, b) => b.distance.compareTo(a.distance));
        break;
      case SortOption.distanceShortest:
        filtered.sort((a, b) => a.distance.compareTo(b.distance));
        break;
      case SortOption.safetyBest:
        filtered.sort((a, b) => b.safetyScore.compareTo(a.safetyScore));
        break;
      case SortOption.safetyWorst:
        filtered.sort((a, b) => a.safetyScore.compareTo(b.safetyScore));
        break;
      case SortOption.speedFastest:
        filtered.sort((a, b) => b.avgSpeed.compareTo(a.avgSpeed));
        break;
      case SortOption.speedSlowest:
        filtered.sort((a, b) => a.avgSpeed.compareTo(b.avgSpeed));
        break;
    }

    return filtered;
  }

  Future<RideStats> calculateStats(List<Ride> rides) async {
    if (rides.isEmpty) {
      return RideStats.empty();
    }

    final totalRides = rides.length;
    final totalDistance = rides.fold<double>(0, (sum, r) => sum + r.distance);
    final totalTime = rides.fold<int>(0, (sum, r) => sum + r.duration);
    final avgSpeed = rides.fold<double>(0, (sum, r) => sum + r.avgSpeed) / totalRides;
    final avgSafetyScore = rides.fold<double>(0, (sum, r) => sum + r.safetyScore) / totalRides;

    final timeOfDayCounts = <String, int>{};
    final dayOfWeekCounts = <String, int>{};

    for (var ride in rides) {
      timeOfDayCounts[ride.timeOfDay] = (timeOfDayCounts[ride.timeOfDay] ?? 0) + 1;
      dayOfWeekCounts[ride.dayOfWeek] = (dayOfWeekCounts[ride.dayOfWeek] ?? 0) + 1;
    }

    final mostCommonTimeOfDay = timeOfDayCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    final mostCommonDayOfWeek = dayOfWeekCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    final distances = rides.map((r) => r.distance).toList();
    final safetyScores = rides.map((r) => r.safetyScore).toList();

    return RideStats(
      totalRides: totalRides,
      totalDistance: totalDistance,
      totalTime: totalTime,
      avgSpeed: avgSpeed,
      avgDistancePerRide: totalDistance / totalRides,
      avgSafetyScore: avgSafetyScore,
      mostCommonTimeOfDay: mostCommonTimeOfDay,
      mostCommonDayOfWeek: mostCommonDayOfWeek,
      longestRide: distances.reduce(max),
      shortestRide: distances.reduce(min),
      bestSafetyScore: safetyScores.reduce(max),
      worstSafetyScore: safetyScores.reduce(min),
    );
  }

  Future<void> _saveRides(List<Ride> rides) async {
    final prefs = await SharedPreferences.getInstance();
    final ridesJson = json.encode(rides.map((r) => r.toJson()).toList());
    await prefs.setString(_ridesKey, ridesJson);
  }

  List<Ride> _generateSampleRides() {
    final random = Random();
    final rides = <Ride>[];
    final now = DateTime.now();

    final terrains = ['urban', 'highway', 'mixed'];
    final timesOfDay = ['morning', 'afternoon', 'evening', 'night'];
    final daysOfWeek = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    for (int i = 0; i < 20; i++) {
      final daysAgo = i * 2;
      final startTime = now.subtract(Duration(days: daysAgo, hours: random.nextInt(12)));
      final duration = 1800 + random.nextInt(3600); // 30-90 minutes
      final endTime = startTime.add(Duration(seconds: duration));
      final distance = 5 + random.nextDouble() * 40; // 5-45 km
      final avgSpeed = 20 + random.nextDouble() * 20; // 20-40 km/h
      final maxSpeed = avgSpeed + 10 + random.nextDouble() * 15;
      final safetyScore = 60 + random.nextDouble() * 40; // 60-100

      final routeCoordinates = <GpsCoordinate>[];
      for (int j = 0; j < 10; j++) {
        routeCoordinates.add(GpsCoordinate(
          latitude: 12.9 + random.nextDouble() * 0.2,
          longitude: 77.5 + random.nextDouble() * 0.2,
          altitude: 800 + random.nextDouble() * 100,
          timestamp: startTime.add(Duration(seconds: j * (duration ~/ 10))),
        ));
      }

      rides.add(Ride(
        rideId: 'ride_${i + 1}',
        userId: 'user_001',
        startTime: startTime,
        endTime: endTime,
        distance: distance,
        duration: duration,
        avgSpeed: avgSpeed,
        maxSpeed: maxSpeed,
        overspeeds: random.nextInt(5),
        routeCoordinates: routeCoordinates,
        safetyScore: safetyScore,
        aiSummary: _generateAiSummary(safetyScore, avgSpeed),
        weatherData: WeatherData(
          temperature: 20 + random.nextDouble() * 15,
          conditions: ['Sunny', 'Cloudy', 'Clear'][random.nextInt(3)],
          humidity: 40 + random.nextDouble() * 40,
          windSpeed: random.nextDouble() * 20,
        ),
        terrain: terrains[random.nextInt(terrains.length)],
        timeOfDay: timesOfDay[random.nextInt(timesOfDay.length)],
        dayOfWeek: daysOfWeek[startTime.weekday - 1],
        memoryCount: random.nextInt(5),
        friendsOnRide: random.nextBool()
            ? ['friend_${random.nextInt(5)}']
            : [],
        createdAt: endTime,
      ));
    }

    return rides;
  }

  String _generateAiSummary(double safetyScore, double avgSpeed) {
    if (safetyScore >= 90) {
      return 'Excellent ride! You maintained safe speeds and followed traffic rules perfectly.';
    } else if (safetyScore >= 75) {
      return 'Good ride with mostly safe practices. Minor overspeeding detected.';
    } else if (safetyScore >= 60) {
      return 'Moderate safety score. Consider reducing speed in urban areas.';
    } else {
      return 'Safety concerns detected. Please be more cautious on your next ride.';
    }
  }
}

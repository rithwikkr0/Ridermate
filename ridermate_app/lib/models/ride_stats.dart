class RideStats {
  final int totalRides;
  final double totalDistance;
  final int totalTime;
  final double avgSpeed;
  final double avgDistancePerRide;
  final double avgSafetyScore;
  final String mostCommonTimeOfDay;
  final String mostCommonDayOfWeek;
  final double longestRide;
  final double shortestRide;
  final double bestSafetyScore;
  final double worstSafetyScore;

  RideStats({
    required this.totalRides,
    required this.totalDistance,
    required this.totalTime,
    required this.avgSpeed,
    required this.avgDistancePerRide,
    required this.avgSafetyScore,
    required this.mostCommonTimeOfDay,
    required this.mostCommonDayOfWeek,
    required this.longestRide,
    required this.shortestRide,
    required this.bestSafetyScore,
    required this.worstSafetyScore,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalRides': totalRides,
      'totalDistance': totalDistance,
      'totalTime': totalTime,
      'avgSpeed': avgSpeed,
      'avgDistancePerRide': avgDistancePerRide,
      'avgSafetyScore': avgSafetyScore,
      'mostCommonTimeOfDay': mostCommonTimeOfDay,
      'mostCommonDayOfWeek': mostCommonDayOfWeek,
      'longestRide': longestRide,
      'shortestRide': shortestRide,
      'bestSafetyScore': bestSafetyScore,
      'worstSafetyScore': worstSafetyScore,
    };
  }

  factory RideStats.fromJson(Map<String, dynamic> json) {
    return RideStats(
      totalRides: json['totalRides'],
      totalDistance: json['totalDistance'].toDouble(),
      totalTime: json['totalTime'],
      avgSpeed: json['avgSpeed'].toDouble(),
      avgDistancePerRide: json['avgDistancePerRide'].toDouble(),
      avgSafetyScore: json['avgSafetyScore'].toDouble(),
      mostCommonTimeOfDay: json['mostCommonTimeOfDay'],
      mostCommonDayOfWeek: json['mostCommonDayOfWeek'],
      longestRide: json['longestRide'].toDouble(),
      shortestRide: json['shortestRide'].toDouble(),
      bestSafetyScore: json['bestSafetyScore'].toDouble(),
      worstSafetyScore: json['worstSafetyScore'].toDouble(),
    );
  }

  String get formattedTotalTime {
    final hours = totalTime ~/ 3600;
    final minutes = (totalTime % 3600) ~/ 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  factory RideStats.empty() {
    return RideStats(
      totalRides: 0,
      totalDistance: 0,
      totalTime: 0,
      avgSpeed: 0,
      avgDistancePerRide: 0,
      avgSafetyScore: 0,
      mostCommonTimeOfDay: 'N/A',
      mostCommonDayOfWeek: 'N/A',
      longestRide: 0,
      shortestRide: 0,
      bestSafetyScore: 0,
      worstSafetyScore: 0,
    );
  }
}

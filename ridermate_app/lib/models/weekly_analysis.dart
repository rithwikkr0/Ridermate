class WeeklyAnalysis {
  final double totalDistance;
  final int totalRides;
  final double avgSafetyScore;
  final int totalPoints;
  final String summary;
  final Map<String, dynamic> trends; // e.g., {'distance': 'up', 'safety': 'stable'}
  final Map<String, dynamic> metrics;
  final DateTime weekStart;
  final DateTime weekEnd;
  final double weekOverWeekChange; // percentage change from previous week

  WeeklyAnalysis({
    required this.totalDistance,
    required this.totalRides,
    required this.avgSafetyScore,
    required this.totalPoints,
    required this.summary,
    required this.trends,
    required this.metrics,
    required this.weekStart,
    required this.weekEnd,
    required this.weekOverWeekChange,
  });

  Map<String, dynamic> toJson() => {
        'totalDistance': totalDistance,
        'totalRides': totalRides,
        'avgSafetyScore': avgSafetyScore,
        'totalPoints': totalPoints,
        'summary': summary,
        'trends': trends,
        'metrics': metrics,
        'weekStart': weekStart.toIso8601String(),
        'weekEnd': weekEnd.toIso8601String(),
        'weekOverWeekChange': weekOverWeekChange,
      };

  factory WeeklyAnalysis.fromJson(Map<String, dynamic> json) => WeeklyAnalysis(
        totalDistance: json['totalDistance']?.toDouble() ?? 0.0,
        totalRides: json['totalRides'] ?? 0,
        avgSafetyScore: json['avgSafetyScore']?.toDouble() ?? 0.0,
        totalPoints: json['totalPoints'] ?? 0,
        summary: json['summary'] ?? '',
        trends: Map<String, dynamic>.from(json['trends'] ?? {}),
        metrics: Map<String, dynamic>.from(json['metrics'] ?? {}),
        weekStart: DateTime.parse(json['weekStart']),
        weekEnd: DateTime.parse(json['weekEnd']),
        weekOverWeekChange: json['weekOverWeekChange']?.toDouble() ?? 0.0,
      );
}

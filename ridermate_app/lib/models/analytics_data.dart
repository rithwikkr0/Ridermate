class AnalyticsData {
  final String period; // '7days', '30days', '90days', '1year', 'all-time'
  final int ridesInPeriod;
  final double distanceInPeriod;
  final int timeInPeriod;
  final double avgSpeedInPeriod;
  final double avgSafetyScoreInPeriod;
  final double improvementVsPrevious;
  final Map<String, int> ridesPerWeek;
  final Map<String, double> distancePerWeek;
  final Map<String, double> safetyScoreTrend;
  final Map<String, int> dayOfWeekDistribution;
  final Map<String, int> timeOfDayDistribution;
  final Map<String, int> terrainDistribution;

  AnalyticsData({
    required this.period,
    required this.ridesInPeriod,
    required this.distanceInPeriod,
    required this.timeInPeriod,
    required this.avgSpeedInPeriod,
    required this.avgSafetyScoreInPeriod,
    required this.improvementVsPrevious,
    required this.ridesPerWeek,
    required this.distancePerWeek,
    required this.safetyScoreTrend,
    required this.dayOfWeekDistribution,
    required this.timeOfDayDistribution,
    required this.terrainDistribution,
  });

  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'ridesInPeriod': ridesInPeriod,
      'distanceInPeriod': distanceInPeriod,
      'timeInPeriod': timeInPeriod,
      'avgSpeedInPeriod': avgSpeedInPeriod,
      'avgSafetyScoreInPeriod': avgSafetyScoreInPeriod,
      'improvementVsPrevious': improvementVsPrevious,
      'ridesPerWeek': ridesPerWeek,
      'distancePerWeek': distancePerWeek,
      'safetyScoreTrend': safetyScoreTrend,
      'dayOfWeekDistribution': dayOfWeekDistribution,
      'timeOfDayDistribution': timeOfDayDistribution,
      'terrainDistribution': terrainDistribution,
    };
  }

  factory AnalyticsData.fromJson(Map<String, dynamic> json) {
    return AnalyticsData(
      period: json['period'],
      ridesInPeriod: json['ridesInPeriod'],
      distanceInPeriod: json['distanceInPeriod'].toDouble(),
      timeInPeriod: json['timeInPeriod'],
      avgSpeedInPeriod: json['avgSpeedInPeriod'].toDouble(),
      avgSafetyScoreInPeriod: json['avgSafetyScoreInPeriod'].toDouble(),
      improvementVsPrevious: json['improvementVsPrevious'].toDouble(),
      ridesPerWeek: Map<String, int>.from(json['ridesPerWeek']),
      distancePerWeek: Map<String, double>.from(
          json['distancePerWeek'].map((k, v) => MapEntry(k, v.toDouble()))),
      safetyScoreTrend: Map<String, double>.from(
          json['safetyScoreTrend'].map((k, v) => MapEntry(k, v.toDouble()))),
      dayOfWeekDistribution: Map<String, int>.from(json['dayOfWeekDistribution']),
      timeOfDayDistribution: Map<String, int>.from(json['timeOfDayDistribution']),
      terrainDistribution: Map<String, int>.from(json['terrainDistribution']),
    );
  }

  factory AnalyticsData.empty(String period) {
    return AnalyticsData(
      period: period,
      ridesInPeriod: 0,
      distanceInPeriod: 0,
      timeInPeriod: 0,
      avgSpeedInPeriod: 0,
      avgSafetyScoreInPeriod: 0,
      improvementVsPrevious: 0,
      ridesPerWeek: {},
      distancePerWeek: {},
      safetyScoreTrend: {},
      dayOfWeekDistribution: {},
      timeOfDayDistribution: {},
      terrainDistribution: {},
    );
  }
}

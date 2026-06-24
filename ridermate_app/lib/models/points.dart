class PointsTransaction {
  final int points;
  final String reason;
  final String activityType;
  final double multiplier;
  final String timestamp;

  PointsTransaction({
    required this.points,
    required this.reason,
    required this.activityType,
    required this.multiplier,
    required this.timestamp,
  });

  factory PointsTransaction.fromJson(Map<String, dynamic> json) {
    return PointsTransaction(
      points: json['points'] ?? 0,
      reason: json['reason'] ?? '',
      activityType: json['activityType'] ?? '',
      multiplier: (json['multiplier'] ?? 1.0).toDouble(),
      timestamp: json['timestamp'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'points': points,
      'reason': reason,
      'activityType': activityType,
      'multiplier': multiplier,
      'timestamp': timestamp,
    };
  }
}

class UserPoints {
  final String userId;
  final int totalPoints;
  final int dailyPoints;
  final int weeklyPoints;
  final List<PointsTransaction> pointHistory;

  UserPoints({
    required this.userId,
    required this.totalPoints,
    required this.dailyPoints,
    required this.weeklyPoints,
    required this.pointHistory,
  });

  factory UserPoints.fromJson(Map<String, dynamic> json) {
    return UserPoints(
      userId: json['userId'] ?? '',
      totalPoints: json['totalPoints'] ?? 0,
      dailyPoints: json['dailyPoints'] ?? 0,
      weeklyPoints: json['weeklyPoints'] ?? 0,
      pointHistory: (json['pointHistory'] as List<dynamic>?)
              ?.map((item) => PointsTransaction.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'totalPoints': totalPoints,
      'dailyPoints': dailyPoints,
      'weeklyPoints': weeklyPoints,
      'pointHistory': pointHistory.map((item) => item.toJson()).toList(),
    };
  }
}

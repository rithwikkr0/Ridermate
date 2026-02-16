class Streak {
  final String userId;
  final int currentStreak;
  final int bestStreak;
  final String? lastRideDate;

  Streak({
    required this.userId,
    required this.currentStreak,
    required this.bestStreak,
    this.lastRideDate,
  });

  factory Streak.fromJson(Map<String, dynamic> json) {
    return Streak(
      userId: json['userId'] ?? '',
      currentStreak: json['currentStreak'] ?? 0,
      bestStreak: json['bestStreak'] ?? 0,
      lastRideDate: json['lastRideDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'lastRideDate': lastRideDate,
    };
  }
}

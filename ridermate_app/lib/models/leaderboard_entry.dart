class LeaderboardEntry {
  final String userId;
  final String username;
  final int rank;
  final int points;
  final double safetyScore;
  final double totalDistance;
  final String? avatarUrl;
  final int? rankChange;

  LeaderboardEntry({
    required this.userId,
    required this.username,
    required this.rank,
    required this.points,
    required this.safetyScore,
    required this.totalDistance,
    this.avatarUrl,
    this.rankChange,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      userId: json['userId'] ?? '',
      username: json['username'] ?? 'User',
      rank: json['rank'] ?? 0,
      points: json['points'] ?? 0,
      safetyScore: (json['safetyScore'] ?? 0).toDouble(),
      totalDistance: (json['totalDistance'] ?? 0).toDouble(),
      avatarUrl: json['avatarUrl'],
      rankChange: json['rankChange'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'rank': rank,
      'points': points,
      'safetyScore': safetyScore,
      'totalDistance': totalDistance,
      'avatarUrl': avatarUrl,
      'rankChange': rankChange,
    };
  }
}

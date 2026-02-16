class Achievement {
  final String achievementId;
  final String name;
  final String description;
  final String type;
  final String icon;
  final bool unlocked;
  final String? unlockedAt;
  final double? progress;
  final int? milestone;

  Achievement({
    required this.achievementId,
    required this.name,
    required this.description,
    required this.type,
    required this.icon,
    required this.unlocked,
    this.unlockedAt,
    this.progress,
    this.milestone,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      achievementId: json['achievementId'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      icon: json['icon'] ?? '🎯',
      unlocked: json['unlocked'] ?? false,
      unlockedAt: json['unlockedAt'],
      progress: json['progress']?.toDouble(),
      milestone: json['milestone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'achievementId': achievementId,
      'name': name,
      'description': description,
      'type': type,
      'icon': icon,
      'unlocked': unlocked,
      'unlockedAt': unlockedAt,
      'progress': progress,
      'milestone': milestone,
    };
  }
}

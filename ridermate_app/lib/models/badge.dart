class Badge {
  final String badgeId;
  final String name;
  final String description;
  final String icon;
  final bool unlocked;
  final String? unlockedAt;
  final double? progress;
  final Map<String, dynamic>? criteria;

  Badge({
    required this.badgeId,
    required this.name,
    required this.description,
    required this.icon,
    required this.unlocked,
    this.unlockedAt,
    this.progress,
    this.criteria,
  });

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      badgeId: json['badgeId'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '🏆',
      unlocked: json['unlocked'] ?? false,
      unlockedAt: json['unlockedAt'],
      progress: json['progress']?.toDouble(),
      criteria: json['criteria'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'badgeId': badgeId,
      'name': name,
      'description': description,
      'icon': icon,
      'unlocked': unlocked,
      'unlockedAt': unlockedAt,
      'progress': progress,
      'criteria': criteria,
    };
  }
}

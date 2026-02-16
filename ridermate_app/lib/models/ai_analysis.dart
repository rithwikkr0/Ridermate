class AIAnalysis {
  final String feedback;
  final List<String> suggestions;
  final double safetyScore; // 0-100
  final String performanceSummary;
  final List<String> strengths;
  final List<String> improvements;
  final DateTime analyzedAt;

  AIAnalysis({
    required this.feedback,
    required this.suggestions,
    required this.safetyScore,
    required this.performanceSummary,
    required this.strengths,
    required this.improvements,
    required this.analyzedAt,
  });

  Map<String, dynamic> toJson() => {
        'feedback': feedback,
        'suggestions': suggestions,
        'safetyScore': safetyScore,
        'performanceSummary': performanceSummary,
        'strengths': strengths,
        'improvements': improvements,
        'analyzedAt': analyzedAt.toIso8601String(),
      };

  factory AIAnalysis.fromJson(Map<String, dynamic> json) => AIAnalysis(
        feedback: json['feedback'] ?? '',
        suggestions: List<String>.from(json['suggestions'] ?? []),
        safetyScore: json['safetyScore']?.toDouble() ?? 0.0,
        performanceSummary: json['performanceSummary'] ?? '',
        strengths: List<String>.from(json['strengths'] ?? []),
        improvements: List<String>.from(json['improvements'] ?? []),
        analyzedAt: DateTime.parse(json['analyzedAt']),
      );
}

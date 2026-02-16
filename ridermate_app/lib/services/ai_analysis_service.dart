import 'dart:convert';
import 'dart:math';
import '../models/ride_metrics.dart';
import '../models/ai_analysis.dart';
import '../models/weekly_analysis.dart';
import 'openai_service.dart';

class AIAnalysisService {
  static final AIAnalysisService _instance = AIAnalysisService._internal();
  factory AIAnalysisService() => _instance;
  AIAnalysisService._internal();

  final OpenAIService _openAIService = OpenAIService();

  // Calculate safety score based on ride metrics
  double calculateSafetyScore(RideMetrics metrics) {
    double score = 100.0;

    // Speed consistency (30 points)
    if (metrics.speedPattern.isNotEmpty) {
      final avgSpeed = metrics.avgSpeed;
      final variance = _calculateVariance(metrics.speedPattern, avgSpeed);
      final consistencyScore = max(0, 30 - (variance * 2));
      score -= (30 - consistencyScore);
    }

    // Overspeed events (40 points)
    final overspeedPenalty = min(40, metrics.overspeeds * 5.0);
    score -= overspeedPenalty;

    // Speed ratio check (30 points)
    if (metrics.avgSpeed > 0) {
      final speedRatio = metrics.maxSpeed / metrics.avgSpeed;
      if (speedRatio > 2.0) {
        // High variance between max and avg indicates unstable riding
        score -= min(30, (speedRatio - 2.0) * 10);
      }
    }

    return max(0, min(100, score));
  }

  double _calculateVariance(List<double> speeds, double avgSpeed) {
    if (speeds.isEmpty) return 0;
    
    double sumSquaredDiff = 0;
    for (var speed in speeds) {
      sumSquaredDiff += pow(speed - avgSpeed, 2);
    }
    return sqrt(sumSquaredDiff / speeds.length);
  }

  Future<AIAnalysis> analyzeRide(RideMetrics metrics, {List<RideMetrics>? rideHistory}) async {
    final safetyScore = calculateSafetyScore(metrics);
    
    // Build context for AI
    final context = _buildRideContext(metrics, safetyScore, rideHistory);
    
    // Get AI analysis
    try {
      final systemPrompt = '''You are RiderMate AI, an expert cycling coach and safety advisor. 
Analyze rides and provide constructive, encouraging feedback focusing on safety and performance.
Keep responses concise and actionable.''';

      final userPrompt = '''Analyze this ride and provide feedback:

$context

Provide:
1. A brief performance summary (2-3 sentences)
2. Top 2-3 strengths
3. Top 2-3 areas for improvement
4. 2-3 specific actionable suggestions

Format as JSON with keys: performanceSummary, strengths (array), improvements (array), suggestions (array)''';

      final response = await _openAIService.chat(
        systemPrompt: systemPrompt,
        userMessage: userPrompt,
      );

      return _parseAIResponse(response, safetyScore);
    } catch (e) {
      // Fallback to rule-based analysis
      return _generateFallbackAnalysis(metrics, safetyScore);
    }
  }

  String _buildRideContext(RideMetrics metrics, double safetyScore, List<RideMetrics>? history) {
    final avgSpeedKmh = metrics.avgSpeed;
    final maxSpeedKmh = metrics.maxSpeed;
    final durationMin = metrics.duration ~/ 60;
    
    String context = '''
Distance: ${metrics.distance.toStringAsFixed(2)} km
Duration: $durationMin minutes
Average Speed: ${avgSpeedKmh.toStringAsFixed(1)} km/h
Max Speed: ${maxSpeedKmh.toStringAsFixed(1)} km/h
Overspeed Events: ${metrics.overspeeds}
Safety Score: ${safetyScore.toStringAsFixed(1)}/100
''';

    if (history != null && history.isNotEmpty) {
      final avgDistance = history.map((r) => r.distance).reduce((a, b) => a + b) / history.length;
      final avgSafety = history.map((r) => calculateSafetyScore(r)).reduce((a, b) => a + b) / history.length;
      
      context += '''
Recent History (${history.length} rides):
- Average distance: ${avgDistance.toStringAsFixed(2)} km
- Average safety score: ${avgSafety.toStringAsFixed(1)}/100
''';
    }

    return context;
  }

  AIAnalysis _parseAIResponse(String response, double safetyScore) {
    try {
      // Try to parse JSON response
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(response);
      if (jsonMatch != null) {
        final jsonStr = jsonMatch.group(0)!;
        final data = jsonDecode(jsonStr);
        
        return AIAnalysis(
          feedback: data['performanceSummary'] ?? response,
          suggestions: List<String>.from(data['suggestions'] ?? []),
          safetyScore: safetyScore,
          performanceSummary: data['performanceSummary'] ?? response,
          strengths: List<String>.from(data['strengths'] ?? []),
          improvements: List<String>.from(data['improvements'] ?? []),
          analyzedAt: DateTime.now(),
        );
      }
    } catch (e) {
      // If JSON parsing fails, use the raw response
    }

    // Fallback: use raw response as feedback
    return AIAnalysis(
      feedback: response,
      suggestions: [],
      safetyScore: safetyScore,
      performanceSummary: response,
      strengths: [],
      improvements: [],
      analyzedAt: DateTime.now(),
    );
  }

  AIAnalysis _generateFallbackAnalysis(RideMetrics metrics, double safetyScore) {
    final strengths = <String>[];
    final improvements = <String>[];
    final suggestions = <String>[];

    // Analyze strengths
    if (safetyScore >= 80) {
      strengths.add('Excellent safety score - well done!');
    }
    if (metrics.overspeeds == 0) {
      strengths.add('No overspeed events - great speed control');
    }
    if (metrics.distance > 20) {
      strengths.add('Great distance covered');
    }

    // Analyze improvements
    if (safetyScore < 70) {
      improvements.add('Safety score could be improved');
      suggestions.add('Focus on maintaining consistent speed');
    }
    if (metrics.overspeeds > 0) {
      improvements.add('Reduce overspeed events');
      suggestions.add('Pay attention to speed limits and adjust your pace accordingly');
    }
    if (metrics.maxSpeed / metrics.avgSpeed > 2.0) {
      improvements.add('High speed variance detected');
      suggestions.add('Try to maintain a more steady pace throughout your ride');
    }

    // Default suggestions
    if (suggestions.isEmpty) {
      suggestions.add('Keep up the great work and stay safe!');
      suggestions.add('Consider tracking your progress over time');
    }

    final performanceSummary = safetyScore >= 80
        ? 'Excellent ride! You maintained good safety practices and steady performance.'
        : safetyScore >= 60
            ? 'Good ride overall. A few areas for improvement to enhance safety.'
            : 'Your ride shows potential. Focus on safety and consistency for better scores.';

    return AIAnalysis(
      feedback: performanceSummary,
      suggestions: suggestions,
      safetyScore: safetyScore,
      performanceSummary: performanceSummary,
      strengths: strengths,
      improvements: improvements,
      analyzedAt: DateTime.now(),
    );
  }

  Future<WeeklyAnalysis> generateWeeklyAnalysis(List<RideMetrics> weekRides) async {
    if (weekRides.isEmpty) {
      return _getEmptyWeeklyAnalysis();
    }

    final totalDistance = weekRides.map((r) => r.distance).reduce((a, b) => a + b);
    final totalRides = weekRides.length;
    final avgSafetyScore = weekRides.map((r) => calculateSafetyScore(r)).reduce((a, b) => a + b) / totalRides;
    final totalPoints = (totalDistance * 10).toInt();

    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: 7));
    final weekEnd = now;

    // Build context for AI weekly summary
    final context = '''
Weekly Cycling Summary:
- Total Rides: $totalRides
- Total Distance: ${totalDistance.toStringAsFixed(2)} km
- Average Safety Score: ${avgSafetyScore.toStringAsFixed(1)}/100
- Points Earned: $totalPoints

Generate a brief, encouraging weekly summary highlighting achievements and suggesting one improvement area.''';

    String summary;
    try {
      summary = await _openAIService.chat(
        systemPrompt: 'You are RiderMate AI, a supportive cycling coach. Provide brief, encouraging weekly summaries.',
        userMessage: context,
      );
    } catch (e) {
      summary = _generateFallbackWeeklySummary(totalRides, totalDistance, avgSafetyScore);
    }

    return WeeklyAnalysis(
      totalDistance: totalDistance,
      totalRides: totalRides,
      avgSafetyScore: avgSafetyScore,
      totalPoints: totalPoints,
      summary: summary,
      trends: {
        'distance': totalDistance > 50 ? 'up' : 'stable',
        'safety': avgSafetyScore > 75 ? 'up' : 'stable',
        'consistency': totalRides >= 5 ? 'up' : 'down',
      },
      metrics: {
        'avgDistancePerRide': totalDistance / totalRides,
        'totalOverspeeds': weekRides.map((r) => r.overspeeds).reduce((a, b) => a + b),
      },
      weekStart: weekStart,
      weekEnd: weekEnd,
      weekOverWeekChange: 0.0, // Would need previous week data
    );
  }

  String _generateFallbackWeeklySummary(int rides, double distance, double safety) {
    if (rides == 0) return 'No rides this week. Let\'s get back on track!';
    
    final avg = distance / rides;
    return 'Great week! $rides rides covering ${distance.toStringAsFixed(1)}km (avg ${avg.toStringAsFixed(1)}km/ride). '
        'Safety score: ${safety.toStringAsFixed(1)}/100. Keep up the momentum!';
  }

  WeeklyAnalysis _getEmptyWeeklyAnalysis() {
    final now = DateTime.now();
    return WeeklyAnalysis(
      totalDistance: 0,
      totalRides: 0,
      avgSafetyScore: 0,
      totalPoints: 0,
      summary: 'No rides recorded this week. Time to get riding!',
      trends: {},
      metrics: {},
      weekStart: now.subtract(Duration(days: 7)),
      weekEnd: now,
      weekOverWeekChange: 0,
    );
  }
}

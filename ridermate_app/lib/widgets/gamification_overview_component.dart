import 'package:flutter/material.dart';
import '../models/points.dart';
import '../services/gamification_api_service.dart';

class GamificationOverviewComponent extends StatefulWidget {
  final String userId;

  const GamificationOverviewComponent({super.key, required this.userId});

  @override
  State<GamificationOverviewComponent> createState() =>
      _GamificationOverviewComponentState();
}

class _GamificationOverviewComponentState
    extends State<GamificationOverviewComponent> {
  UserPoints? userPoints;
  Map<String, dynamic> rankData = {};
  int badgeCount = 0;
  int achievementCount = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final points = await GamificationApiService.getUserPoints(widget.userId);
    final rank = await GamificationApiService.getUserRank(widget.userId);
    final badges = await GamificationApiService.getUserBadges(widget.userId);
    final achievements =
        await GamificationApiService.getUserAchievements(widget.userId);

    setState(() {
      userPoints = points;
      rankData = rank;
      badgeCount = badges.length;
      achievementCount = achievements.length;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF0066FF)),
      );
    }

    final rank = rankData['rank'] ?? 0;
    final points = userPoints?.totalPoints ?? 0;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gamification Overview',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Stats Grid
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Rank',
                  '#$rank',
                  Icons.leaderboard,
                  const Color(0xFF0066FF),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Points',
                  '$points',
                  Icons.stars,
                  const Color(0xFFFF6B35),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Badges',
                  '$badgeCount',
                  Icons.emoji_events,
                  const Color(0xFFFFD700),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Achievements',
                  '$achievementCount',
                  Icons.military_tech,
                  const Color(0xFF4CAF50),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Daily/Weekly Progress
          _buildProgressBar(
            'Daily Points',
            userPoints?.dailyPoints ?? 0,
            500,
            const Color(0xFF0066FF),
          ),

          const SizedBox(height: 12),

          _buildProgressBar(
            'Weekly Points',
            userPoints?.weeklyPoints ?? 0,
            2000,
            const Color(0xFFFF6B35),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, int current, int max, Color color) {
    final progress = current / max;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$current / $max',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: Colors.grey[800],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}

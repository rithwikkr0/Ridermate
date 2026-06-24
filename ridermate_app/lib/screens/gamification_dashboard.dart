import 'package:flutter/material.dart';
import '../widgets/user_rank_card.dart';
import '../widgets/badges_component.dart';
import '../widgets/achievements_component.dart';
import '../widgets/points_history_component.dart';
import '../widgets/gamification_overview_component.dart';
import '../widgets/streak_component.dart';
import './leaderboard_page.dart';

class GamificationDashboard extends StatefulWidget {
  final String userId;

  const GamificationDashboard({super.key, required this.userId});

  @override
  State<GamificationDashboard> createState() => _GamificationDashboardState();
}

class _GamificationDashboardState extends State<GamificationDashboard> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Gamification',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LeaderboardPage(userId: widget.userId),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Tab Navigation
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildTab('Overview', 0),
                  const SizedBox(width: 10),
                  _buildTab('Badges', 1),
                  const SizedBox(width: 10),
                  _buildTab('Achievements', 2),
                  const SizedBox(width: 10),
                  _buildTab('History', 3),
                ],
              ),
            ),

            // Content based on selected tab
            if (selectedTab == 0) ...[
              // Overview Tab
              UserRankCard(userId: widget.userId),
              StreakComponent(currentStreak: 5, bestStreak: 12),
              GamificationOverviewComponent(userId: widget.userId),
              BadgesComponent(userId: widget.userId),
            ] else if (selectedTab == 1) ...[
              // Badges Tab
              const SizedBox(height: 20),
              BadgesComponent(userId: widget.userId),
            ] else if (selectedTab == 2) ...[
              // Achievements Tab
              const SizedBox(height: 20),
              AchievementsComponent(userId: widget.userId),
            ] else if (selectedTab == 3) ...[
              // History Tab
              const SizedBox(height: 20),
              PointsHistoryComponent(userId: widget.userId),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0066FF) : Colors.grey[800],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

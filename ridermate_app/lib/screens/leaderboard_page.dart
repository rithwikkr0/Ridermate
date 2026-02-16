import 'package:flutter/material.dart';
import '../models/leaderboard_entry.dart';
import '../services/gamification_api_service.dart';

class LeaderboardPage extends StatefulWidget {
  final String userId;

  const LeaderboardPage({super.key, required this.userId});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  String selectedTab = 'global';
  String selectedPeriod = 'all_time';
  String selectedFilter = 'points';
  List<LeaderboardEntry> leaderboardData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadLeaderboard();
  }

  Future<void> loadLeaderboard() async {
    setState(() => isLoading = true);

    List<LeaderboardEntry> data = [];

    if (selectedTab == 'global') {
      data = await GamificationApiService.getGlobalLeaderboard(
        period: selectedPeriod,
      );
    } else if (selectedTab == 'friends') {
      data = await GamificationApiService.getFriendsLeaderboard(
        widget.userId,
        period: selectedPeriod,
      );
    }

    setState(() {
      leaderboardData = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Leaderboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Tab Selection
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildTabButton('Global', 'global'),
                const SizedBox(width: 10),
                _buildTabButton('Friends', 'friends'),
              ],
            ),
          ),

          // Period Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip('Weekly', 'weekly'),
                const SizedBox(width: 8),
                _buildFilterChip('Monthly', 'monthly'),
                const SizedBox(width: 8),
                _buildFilterChip('All Time', 'all_time'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Leaderboard List
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF0066FF),
                    ),
                  )
                : leaderboardData.isEmpty
                    ? const Center(
                        child: Text(
                          'No data available',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: leaderboardData.length,
                        itemBuilder: (context, index) {
                          final entry = leaderboardData[index];
                          final isCurrentUser = entry.userId == widget.userId;

                          return _buildLeaderboardCard(entry, isCurrentUser);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, String value) {
    final isSelected = selectedTab == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => selectedTab = value);
          loadLeaderboard();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0066FF) : Colors.grey[800],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = selectedPeriod == value;
    return GestureDetector(
      onTap: () {
        setState(() => selectedPeriod = value);
        loadLeaderboard();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0066FF) : Colors.grey[850],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF0066FF) : Colors.grey[700]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardCard(LeaderboardEntry entry, bool isCurrentUser) {
    Color rankColor;
    if (entry.rank == 1) {
      rankColor = const Color(0xFFFFD700); // Gold
    } else if (entry.rank == 2) {
      rankColor = const Color(0xFFC0C0C0); // Silver
    } else if (entry.rank == 3) {
      rankColor = const Color(0xFFCD7F32); // Bronze
    } else {
      rankColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrentUser ? const Color(0xFF0066FF).withOpacity(0.2) : Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentUser ? const Color(0xFF0066FF) : Colors.transparent,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Rank Badge
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: rankColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${entry.rank}',
                style: TextStyle(
                  color: rankColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${entry.totalDistance.toStringAsFixed(1)} km • Safety: ${entry.safetyScore.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Points
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.points}',
                style: const TextStyle(
                  color: Color(0xFFFF6B35),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'pts',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

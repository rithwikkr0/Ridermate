import 'package:flutter/material.dart';
import '../models/achievement.dart';
import '../services/gamification_api_service.dart';

class AchievementsComponent extends StatefulWidget {
  final String userId;

  const AchievementsComponent({super.key, required this.userId});

  @override
  State<AchievementsComponent> createState() => _AchievementsComponentState();
}

class _AchievementsComponentState extends State<AchievementsComponent> {
  List<Achievement> achievements = [];
  bool isLoading = true;
  String selectedType = 'all';

  @override
  void initState() {
    super.initState();
    loadAchievements();
  }

  Future<void> loadAchievements() async {
    final allAchievements = await GamificationApiService.getAllAchievements();
    setState(() {
      achievements = allAchievements;
      isLoading = false;
    });
  }

  List<Achievement> getFilteredAchievements() {
    if (selectedType == 'all') return achievements;
    return achievements.where((a) => a.type == selectedType).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF0066FF)),
      );
    }

    final filteredAchievements = getFilteredAchievements();
    final unlockedCount = filteredAchievements.where((a) => a.unlocked).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Achievements',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B35),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$unlockedCount/${filteredAchievements.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Type Filter
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _buildFilterChip('All', 'all'),
              const SizedBox(width: 8),
              _buildFilterChip('Milestone', 'milestone'),
              const SizedBox(width: 8),
              _buildFilterChip('Skill', 'skill'),
              const SizedBox(width: 8),
              _buildFilterChip('Social', 'social'),
              const SizedBox(width: 8),
              _buildFilterChip('Time Based', 'time_based'),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Achievements List
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: filteredAchievements.length,
          itemBuilder: (context, index) {
            final achievement = filteredAchievements[index];
            return _buildAchievementCard(achievement);
          },
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = selectedType == value;
    return GestureDetector(
      onTap: () {
        setState(() => selectedType = value);
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

  Widget _buildAchievementCard(Achievement achievement) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: achievement.unlocked
            ? const Color(0xFFFF6B35).withOpacity(0.1)
            : Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: achievement.unlocked
              ? const Color(0xFFFF6B35)
              : Colors.grey[800]!,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: achievement.unlocked
                  ? const Color(0xFFFF6B35).withOpacity(0.2)
                  : Colors.grey[850],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Opacity(
                opacity: achievement.unlocked ? 1.0 : 0.3,
                child: Text(
                  achievement.icon,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        achievement.name,
                        style: TextStyle(
                          color: achievement.unlocked ? Colors.white : Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (achievement.unlocked)
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFFFF6B35),
                        size: 20,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
                if (!achievement.unlocked && achievement.progress != null) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (achievement.progress ?? 0) / 100,
                      backgroundColor: Colors.grey[800],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFFF6B35),
                      ),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(achievement.progress ?? 0).toStringAsFixed(0)}% Complete',
                    style: const TextStyle(
                      color: Color(0xFFFF6B35),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

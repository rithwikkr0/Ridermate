import 'package:flutter/material.dart';
import '../models/badge.dart';
import '../services/gamification_api_service.dart';

class BadgesComponent extends StatefulWidget {
  final String userId;

  const BadgesComponent({super.key, required this.userId});

  @override
  State<BadgesComponent> createState() => _BadgesComponentState();
}

class _BadgesComponentState extends State<BadgesComponent> {
  List<Badge> badges = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadBadges();
  }

  Future<void> loadBadges() async {
    final allBadges = await GamificationApiService.getAllBadges();
    final userBadges = await GamificationApiService.getUserBadges(widget.userId);

    // Merge data to show progress
    final mergedBadges = allBadges.map((badge) {
      final userBadge = userBadges.firstWhere(
        (ub) => ub.badgeId == badge.badgeId,
        orElse: () => Badge(
          badgeId: badge.badgeId,
          name: badge.name,
          description: badge.description,
          icon: badge.icon,
          unlocked: false,
        ),
      );

      return Badge(
        badgeId: badge.badgeId,
        name: badge.name,
        description: badge.description,
        icon: badge.icon,
        unlocked: userBadge.unlocked,
        unlockedAt: userBadge.unlockedAt,
        progress: userBadge.progress ?? 0,
        criteria: badge.criteria,
      );
    }).toList();

    setState(() {
      badges = mergedBadges;
      isLoading = false;
    });
  }

  void showBadgeDetails(Badge badge) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              badge.icon,
              style: const TextStyle(fontSize: 60),
            ),
            const SizedBox(height: 16),
            Text(
              badge.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              badge.description,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (!badge.unlocked) ...[
              const Text(
                'Progress',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (badge.progress ?? 0) / 100,
                backgroundColor: Colors.grey[800],
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF0066FF),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${(badge.progress ?? 0).toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: Color(0xFF0066FF),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Unlocked!',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF0066FF)),
      );
    }

    final unlockedCount = badges.where((b) => b.unlocked).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Badges',
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
                  color: const Color(0xFF0066FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$unlockedCount/${badges.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: badges.length,
            itemBuilder: (context, index) {
              final badge = badges[index];
              return GestureDetector(
                onTap: () => showBadgeDetails(badge),
                child: Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: badge.unlocked
                        ? const Color(0xFF0066FF).withOpacity(0.2)
                        : Colors.grey[900],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: badge.unlocked
                          ? const Color(0xFF0066FF)
                          : Colors.grey[800]!,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Opacity(
                        opacity: badge.unlocked ? 1.0 : 0.3,
                        child: Text(
                          badge.icon,
                          style: const TextStyle(fontSize: 40),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        badge.name,
                        style: TextStyle(
                          color: badge.unlocked ? Colors.white : Colors.grey,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (!badge.unlocked) ...[
                        const SizedBox(height: 4),
                        Container(
                          width: double.infinity,
                          height: 3,
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: (badge.progress ?? 0) / 100,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF0066FF),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

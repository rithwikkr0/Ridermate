import 'package:flutter/material.dart';
import '../models/ride_metrics.dart';
import '../models/ai_analysis.dart';
import '../services/ai_analysis_service.dart';

class RideHistoryWithAI extends StatelessWidget {
  final List<RideMetrics> rides;
  final Function(RideMetrics)? onRideTap;

  const RideHistoryWithAI({
    Key? key,
    required this.rides,
    this.onRideTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (rides.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // Statistics Header
        _buildStatsHeader(),
        SizedBox(height: 20),

        // Rides List
        ...rides.asMap().entries.map((entry) {
          final index = entry.key;
          final ride = entry.value;
          return _buildRideCard(context, ride, index);
        }).toList(),
      ],
    );
  }

  Widget _buildStatsHeader() {
    final totalDistance = rides.map((r) => r.distance).reduce((a, b) => a + b);
    final avgSafety = rides.map((r) {
      return AIAnalysisService().calculateSafetyScore(r);
    }).reduce((a, b) => a + b) / rides.length;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0066FF), Color(0xFF004499)],
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            label: 'Total Rides',
            value: '${rides.length}',
            icon: Icons.directions_bike,
          ),
          Container(width: 1, height: 40, color: Colors.white24),
          _buildStatItem(
            label: 'Total Distance',
            value: '${totalDistance.toStringAsFixed(1)}km',
            icon: Icons.route,
          ),
          Container(width: 1, height: 40, color: Colors.white24),
          _buildStatItem(
            label: 'Avg Safety',
            value: '${avgSafety.toStringAsFixed(0)}',
            icon: Icons.shield,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildRideCard(BuildContext context, RideMetrics ride, int index) {
    final service = AIAnalysisService();
    final safetyScore = service.calculateSafetyScore(ride);
    final scoreColor = _getSafetyColor(safetyScore);
    
    return GestureDetector(
      onTap: () => onRideTap?.call(ride),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: scoreColor.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Color(0xFF0066FF).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.directions_bike,
                        color: Color(0xFF0066FF),
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ride #${rides.length - index}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _formatDate(ride.timestamp),
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Safety Score Badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: scoreColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: scoreColor, width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shield, color: scoreColor, size: 14),
                      SizedBox(width: 5),
                      Text(
                        '${safetyScore.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: scoreColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),

            // Metrics Row
            Row(
              children: [
                _buildMetric(
                  icon: Icons.straighten,
                  label: 'Distance',
                  value: '${ride.distance.toStringAsFixed(1)} km',
                ),
                SizedBox(width: 20),
                _buildMetric(
                  icon: Icons.timer,
                  label: 'Duration',
                  value: '${(ride.duration ~/ 60)} min',
                ),
                SizedBox(width: 20),
                _buildMetric(
                  icon: Icons.speed,
                  label: 'Avg Speed',
                  value: '${ride.avgSpeed.toStringAsFixed(1)} km/h',
                ),
              ],
            ),

            // Warning if overspeeds
            if (ride.overspeeds > 0) ...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(0xFFCC0000).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning, color: Color(0xFFCC0000), size: 14),
                    SizedBox(width: 6),
                    Text(
                      '${ride.overspeeds} overspeed event${ride.overspeeds > 1 ? 's' : ''}',
                      style: TextStyle(
                        color: Color(0xFFCC0000),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // AI Insight
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: Color(0xFF0066FF),
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getQuickInsight(ride, safetyScore),
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.grey, size: 14),
              SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 80,
              color: Colors.grey[700],
            ),
            SizedBox(height: 20),
            Text(
              'No Rides Yet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Start your first ride to see AI-powered insights!',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getSafetyColor(double score) {
    if (score >= 80) return Color(0xFF4CAF50);
    if (score >= 60) return Color(0xFFFF6B35);
    return Color(0xFFCC0000);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }

  String _getQuickInsight(RideMetrics ride, double safetyScore) {
    if (safetyScore >= 90) {
      return 'Outstanding safety performance! Keep it up! 🌟';
    } else if (safetyScore >= 80) {
      return 'Great ride with excellent safety practices! 👍';
    } else if (safetyScore >= 70) {
      return 'Good ride! Minor improvements can boost your score.';
    } else if (safetyScore >= 60) {
      return 'Fair ride. Focus on maintaining consistent speed.';
    } else {
      return 'Room for improvement. Check AI suggestions for tips.';
    }
  }
}

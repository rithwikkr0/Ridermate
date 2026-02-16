import 'package:flutter/material.dart';
import '../models/weekly_analysis.dart';

class WeeklyAnalysisCard extends StatelessWidget {
  final WeeklyAnalysis analysis;

  const WeeklyAnalysisCard({
    Key? key,
    required this.analysis,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Color(0xFF0066FF).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF0066FF).withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Weekly Summary',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    _formatDateRange(analysis.weekStart, analysis.weekEnd),
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  color: Color(0xFFFF6B35),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${analysis.totalPoints} pts',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 25),

          // Metrics Grid
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  label: 'Total Distance',
                  value: '${analysis.totalDistance.toStringAsFixed(1)} km',
                  icon: Icons.route,
                  trend: analysis.trends['distance'],
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: _buildMetricCard(
                  label: 'Total Rides',
                  value: '${analysis.totalRides}',
                  icon: Icons.directions_bike,
                  trend: analysis.trends['consistency'],
                ),
              ),
            ],
          ),
          SizedBox(height: 15),

          // Safety Score
          _buildSafetyMetric(),
          SizedBox(height: 20),

          // AI Summary
          Container(
            padding: EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Color(0xFF0066FF).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: Color(0xFF0066FF),
                  size: 20,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    analysis.summary,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Week over week comparison
          if (analysis.weekOverWeekChange != 0) ...[
            SizedBox(height: 15),
            _buildComparisonRow(),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required IconData icon,
    String? trend,
  }) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Color(0xFF0066FF), size: 18),
              if (trend != null) ...[
                Spacer(),
                _buildTrendIndicator(trend),
              ],
            ],
          ),
          SizedBox(height: 10),
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
              color: Colors.grey,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyMetric() {
    final score = analysis.avgSafetyScore;
    final color = _getSafetyColor(score);
    
    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.shield,
                color: color,
                size: 28,
              ),
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Average Safety Score',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    Text(
                      '${score.toStringAsFixed(1)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      ' / 100',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _buildTrendIndicator(analysis.trends['safety'] ?? 'stable'),
        ],
      ),
    );
  }

  Widget _buildTrendIndicator(String trend) {
    IconData icon;
    Color color;

    switch (trend) {
      case 'up':
        icon = Icons.trending_up;
        color = Color(0xFF4CAF50);
        break;
      case 'down':
        icon = Icons.trending_down;
        color = Color(0xFFCC0000);
        break;
      default:
        icon = Icons.trending_flat;
        color = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icon, color: color, size: 16),
    );
  }

  Widget _buildComparisonRow() {
    final change = analysis.weekOverWeekChange;
    final isPositive = change > 0;
    
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (isPositive ? Color(0xFF4CAF50) : Color(0xFFCC0000))
            .withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isPositive ? Icons.arrow_upward : Icons.arrow_downward,
            color: isPositive ? Color(0xFF4CAF50) : Color(0xFFCC0000),
            size: 16,
          ),
          SizedBox(width: 8),
          Text(
            '${change.abs().toStringAsFixed(1)}% vs last week',
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

  Color _getSafetyColor(double score) {
    if (score >= 80) return Color(0xFF4CAF50);
    if (score >= 60) return Color(0xFFFF6B35);
    return Color(0xFFCC0000);
  }

  String _formatDateRange(DateTime start, DateTime end) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    return '${months[start.month - 1]} ${start.day} - ${months[end.month - 1]} ${end.day}';
  }
}

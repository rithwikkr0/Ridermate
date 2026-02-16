import 'package:flutter/material.dart';
import '../models/ride_stats.dart';

class RideStatsWidget extends StatelessWidget {
  final RideStats stats;

  const RideStatsWidget({Key? key, required this.stats}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overall Statistics',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          _buildStatsGrid(),
          SizedBox(height: 20),
          Divider(color: Colors.grey[800]),
          SizedBox(height: 20),
          _buildBestWorstSection(),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Rides',
                '${stats.totalRides}',
                Icons.directions_bike,
                Color(0xFF0066FF),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Total Distance',
                '${stats.totalDistance.toStringAsFixed(1)} km',
                Icons.route,
                Color(0xFF4CAF50),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Time',
                stats.formattedTotalTime,
                Icons.timer,
                Color(0xFFFF6B35),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Avg Speed',
                '${stats.avgSpeed.toStringAsFixed(1)} km/h',
                Icons.speed,
                Color(0xFF9C27B0),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Avg Distance',
                '${stats.avgDistancePerRide.toStringAsFixed(1)} km',
                Icons.trending_up,
                Color(0xFF00BCD4),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Avg Safety',
                '${stats.avgSafetyScore.toStringAsFixed(1)}',
                Icons.shield,
                Color(0xFFFFEB3B),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
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
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildBestWorstSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Records',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        _buildRecordRow(
          'Longest Ride',
          '${stats.longestRide.toStringAsFixed(1)} km',
          Icons.star,
          Colors.amber,
        ),
        SizedBox(height: 8),
        _buildRecordRow(
          'Shortest Ride',
          '${stats.shortestRide.toStringAsFixed(1)} km',
          Icons.minimize,
          Colors.blue,
        ),
        SizedBox(height: 8),
        _buildRecordRow(
          'Best Safety',
          '${stats.bestSafetyScore.toStringAsFixed(0)}',
          Icons.shield_outlined,
          Colors.green,
        ),
        SizedBox(height: 8),
        _buildRecordRow(
          'Most Common Day',
          stats.mostCommonDayOfWeek,
          Icons.calendar_today,
          Colors.purple,
        ),
        SizedBox(height: 8),
        _buildRecordRow(
          'Most Common Time',
          stats.mostCommonTimeOfDay,
          Icons.access_time,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildRecordRow(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

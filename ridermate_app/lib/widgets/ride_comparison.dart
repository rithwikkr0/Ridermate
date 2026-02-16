import 'package:flutter/material.dart';
import '../models/ride.dart';
import '../services/analytics_service.dart';
import 'package:intl/intl.dart';

class RideComparison extends StatelessWidget {
  final Ride ride1;
  final Ride ride2;

  const RideComparison({
    super.key,
    required this.ride1,
    required this.ride2,
  });

  @override
  Widget build(BuildContext context) {
    final analyticsService = AnalyticsService();
    final comparison = analyticsService.compareRides(ride1, ride2);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: Text(
          'Compare Rides',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRideHeaders(),
            SizedBox(height: 20),
            _buildComparisonMetric(
              'Distance',
              comparison['distance'],
              'km',
              Icons.route,
            ),
            SizedBox(height: 12),
            _buildComparisonMetric(
              'Duration',
              comparison['duration'],
              's',
              Icons.timer,
            ),
            SizedBox(height: 12),
            _buildComparisonMetric(
              'Average Speed',
              comparison['avgSpeed'],
              'km/h',
              Icons.speed,
            ),
            SizedBox(height: 12),
            _buildComparisonMetric(
              'Max Speed',
              comparison['maxSpeed'],
              'km/h',
              Icons.speed,
            ),
            SizedBox(height: 12),
            _buildComparisonMetric(
              'Safety Score',
              comparison['safetyScore'],
              '',
              Icons.shield,
            ),
            SizedBox(height: 20),
            _buildAdditionalComparison(),
          ],
        ),
      ),
    );
  }

  Widget _buildRideHeaders() {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF0066FF).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFF0066FF)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ride 1',
                  style: TextStyle(
                    color: Color(0xFF0066FF),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  dateFormat.format(ride1.startTime),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  ride1.rideId,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF4CAF50).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFF4CAF50)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ride 2',
                  style: TextStyle(
                    color: Color(0xFF4CAF50),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  dateFormat.format(ride2.startTime),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  ride2.rideId,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonMetric(
    String label,
    Map<String, dynamic> data,
    String unit,
    IconData icon,
  ) {
    final ride1Value = data['ride1'];
    final ride2Value = data['ride2'];
    final delta = data['delta'];
    final deltaPercent = data['deltaPercent'];

    final isRide1Better = delta > 0;
    final deltaColor = delta > 0 ? Color(0xFF0066FF) : Color(0xFF4CAF50);

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.grey, size: 20),
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ride 1',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${ride1Value.toStringAsFixed(2)} $unit',
                      style: TextStyle(
                        color: isRide1Better ? Color(0xFF4CAF50) : Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: deltaColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(
                      isRide1Better ? Icons.arrow_upward : Icons.arrow_downward,
                      color: deltaColor,
                      size: 16,
                    ),
                    Text(
                      '${delta.abs().toStringAsFixed(1)}',
                      style: TextStyle(
                        color: deltaColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${deltaPercent.abs().toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: deltaColor,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Ride 2',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${ride2Value.toStringAsFixed(2)} $unit',
                      style: TextStyle(
                        color: !isRide1Better ? Color(0xFF4CAF50) : Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalComparison() {
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
            'Additional Comparison',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          _buildComparisonRow('Terrain', ride1.terrain, ride2.terrain),
          _buildComparisonRow('Time of Day', ride1.timeOfDay, ride2.timeOfDay),
          _buildComparisonRow('Day of Week', ride1.dayOfWeek, ride2.dayOfWeek),
          _buildComparisonRow('Overspeeds', '${ride1.overspeeds}', '${ride2.overspeeds}'),
          _buildComparisonRow('Memories', '${ride1.memoryCount}', '${ride2.memoryCount}'),
          if (ride1.weatherData != null && ride2.weatherData != null)
            _buildComparisonRow(
              'Weather',
              '${ride1.weatherData!.temperature.toStringAsFixed(1)}°C, ${ride1.weatherData!.conditions}',
              '${ride2.weatherData!.temperature.toStringAsFixed(1)}°C, ${ride2.weatherData!.conditions}',
            ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(String label, String value1, String value2) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  value1,
                  style: TextStyle(color: Color(0xFF0066FF), fontSize: 14),
                ),
              ),
              Icon(Icons.compare_arrows, color: Colors.grey, size: 16),
              Expanded(
                child: Text(
                  value2,
                  textAlign: TextAlign.right,
                  style: TextStyle(color: Color(0xFF4CAF50), fontSize: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

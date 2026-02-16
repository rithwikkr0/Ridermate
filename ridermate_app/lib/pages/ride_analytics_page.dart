import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/ride.dart';
import '../models/analytics_data.dart';
import '../services/ride_history_service.dart';
import '../services/analytics_service.dart';
import '../services/data_export_service.dart';

class RideAnalyticsPage extends StatefulWidget {
  final String userId;

  const RideAnalyticsPage({super.key, required this.userId});

  @override
  _RideAnalyticsPageState createState() => _RideAnalyticsPageState();
}

class _RideAnalyticsPageState extends State<RideAnalyticsPage> {
  final RideHistoryService _historyService = RideHistoryService();
  final AnalyticsService _analyticsService = AnalyticsService();
  final DataExportService _exportService = DataExportService();

  List<Ride> _rides = [];
  AnalyticsData? _analyticsData;
  String _selectedPeriod = '30days';
  bool _isLoading = true;

  final List<String> _periods = [
    '7days',
    '30days',
    '90days',
    '1year',
    'all-time'
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final rides = await _historyService.getUserRides(widget.userId);
      final analytics = _analyticsService.calculateAnalytics(rides, _selectedPeriod);
      setState(() {
        _rides = rides;
        _analyticsData = analytics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading analytics: $e')),
      );
    }
  }

  Future<void> _exportData() async {
    try {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text('Export Data', style: TextStyle(color: Colors.white)),
          content: Text(
            'Choose export format:',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final file = await _exportService.exportToCSV(_rides, widget.userId);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Exported to ${file.path}')),
                );
              },
              child: Text('CSV'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final file = await _exportService.exportToJSON(_rides, widget.userId);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Exported to ${file.path}')),
                );
              },
              child: Text('JSON'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exporting data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: Text(
          'Ride Analytics',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.download, color: Colors.white),
            onPressed: _exportData,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPeriodSelector(),
                  SizedBox(height: 20),
                  if (_analyticsData != null) ...[
                    _buildSummaryCards(),
                    SizedBox(height: 20),
                    _buildDistanceChart(),
                    SizedBox(height: 20),
                    _buildRidesChart(),
                    SizedBox(height: 20),
                    _buildSafetyTrendChart(),
                    SizedBox(height: 20),
                    _buildDayOfWeekHeatmap(),
                    SizedBox(height: 20),
                    _buildTimeOfDayPieChart(),
                    SizedBox(height: 20),
                    _buildTerrainPieChart(),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: _periods.map((period) {
          final isSelected = period == _selectedPeriod;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPeriod = period;
                });
                _loadData();
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Color(0xFF0066FF) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    _formatPeriodLabel(period),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _formatPeriodLabel(String period) {
    switch (period) {
      case '7days':
        return '7D';
      case '30days':
        return '30D';
      case '90days':
        return '90D';
      case '1year':
        return '1Y';
      case 'all-time':
        return 'All';
      default:
        return period;
    }
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Rides',
            '${_analyticsData!.ridesInPeriod}',
            Icons.directions_bike,
            Color(0xFF0066FF),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Distance',
            '${_analyticsData!.distanceInPeriod.toStringAsFixed(1)} km',
            Icons.route,
            Color(0xFF4CAF50),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Improvement',
            '${_analyticsData!.improvementVsPrevious >= 0 ? '+' : ''}${_analyticsData!.improvementVsPrevious.toStringAsFixed(1)}%',
            _analyticsData!.improvementVsPrevious >= 0
                ? Icons.trending_up
                : Icons.trending_down,
            _analyticsData!.improvementVsPrevious >= 0
                ? Color(0xFF4CAF50)
                : Color(0xFFFF6B35),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
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

  Widget _buildDistanceChart() {
    if (_analyticsData!.distancePerWeek.isEmpty) {
      return _buildEmptyChart('No distance data available');
    }

    final sortedEntries = _analyticsData!.distancePerWeek.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return _buildChartContainer(
      'Distance per Week',
      LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}km',
                    style: TextStyle(color: Colors.grey, fontSize: 10),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: sortedEntries
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value.value))
                  .toList(),
              isCurved: true,
              color: Color(0xFF0066FF),
              barWidth: 3,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Color(0xFF0066FF).withOpacity(0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRidesChart() {
    if (_analyticsData!.ridesPerWeek.isEmpty) {
      return _buildEmptyChart('No rides data available');
    }

    final sortedEntries = _analyticsData!.ridesPerWeek.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return _buildChartContainer(
      'Rides per Week',
      BarChart(
        BarChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}',
                    style: TextStyle(color: Colors.grey, fontSize: 10),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: sortedEntries
              .asMap()
              .entries
              .map(
                (e) => BarChartGroupData(
                  x: e.key,
                  barRods: [
                    BarChartRodData(
                      toY: e.value.value.toDouble(),
                      color: Color(0xFF4CAF50),
                      width: 16,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildSafetyTrendChart() {
    if (_analyticsData!.safetyScoreTrend.isEmpty) {
      return _buildEmptyChart('No safety data available');
    }

    final sortedEntries = _analyticsData!.safetyScoreTrend.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return _buildChartContainer(
      'Safety Score Trend',
      LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}',
                    style: TextStyle(color: Colors.grey, fontSize: 10),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: sortedEntries
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value.value))
                  .toList(),
              isCurved: true,
              color: Color(0xFFFFEB3B),
              barWidth: 3,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Color(0xFFFFEB3B).withOpacity(0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayOfWeekHeatmap() {
    if (_analyticsData!.dayOfWeekDistribution.isEmpty) {
      return _buildEmptyChart('No day distribution data');
    }

    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final maxValue = _analyticsData!.dayOfWeekDistribution.values
        .reduce((a, b) => a > b ? a : b)
        .toDouble();

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
            'Rides by Day of Week',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Column(
            children: days.map((day) {
              final count = _analyticsData!.dayOfWeekDistribution[day] ?? 0;
              final intensity = maxValue > 0 ? count / maxValue : 0.0;
              return Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        day.substring(0, 3),
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.grey[850],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: intensity,
                            child: Container(
                              height: 24,
                              decoration: BoxDecoration(
                                color: Color(0xFF0066FF),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Center(
                                child: Text(
                                  '$count',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeOfDayPieChart() {
    if (_analyticsData!.timeOfDayDistribution.isEmpty) {
      return _buildEmptyChart('No time of day data');
    }

    return _buildChartContainer(
      'Rides by Time of Day',
      PieChart(
        PieChartData(
          sections: _analyticsData!.timeOfDayDistribution.entries.map((entry) {
            final color = _getTimeOfDayColor(entry.key);
            return PieChartSectionData(
              value: entry.value.toDouble(),
              title: '${entry.value}',
              color: color,
              radius: 80,
              titleStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            );
          }).toList(),
          sectionsSpace: 2,
          centerSpaceRadius: 40,
        ),
      ),
      height: 240,
      legend: _analyticsData!.timeOfDayDistribution.keys.map((key) {
        return {
          'label': key,
          'color': _getTimeOfDayColor(key),
        };
      }).toList(),
    );
  }

  Widget _buildTerrainPieChart() {
    if (_analyticsData!.terrainDistribution.isEmpty) {
      return _buildEmptyChart('No terrain data');
    }

    return _buildChartContainer(
      'Rides by Terrain',
      PieChart(
        PieChartData(
          sections: _analyticsData!.terrainDistribution.entries.map((entry) {
            final color = _getTerrainColor(entry.key);
            return PieChartSectionData(
              value: entry.value.toDouble(),
              title: '${entry.value}',
              color: color,
              radius: 80,
              titleStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            );
          }).toList(),
          sectionsSpace: 2,
          centerSpaceRadius: 40,
        ),
      ),
      height: 240,
      legend: _analyticsData!.terrainDistribution.keys.map((key) {
        return {
          'label': key,
          'color': _getTerrainColor(key),
        };
      }).toList(),
    );
  }

  Color _getTimeOfDayColor(String timeOfDay) {
    switch (timeOfDay) {
      case 'morning':
        return Color(0xFFFFEB3B);
      case 'afternoon':
        return Color(0xFFFF9800);
      case 'evening':
        return Color(0xFF9C27B0);
      case 'night':
        return Color(0xFF3F51B5);
      default:
        return Colors.grey;
    }
  }

  Color _getTerrainColor(String terrain) {
    switch (terrain) {
      case 'urban':
        return Color(0xFF2196F3);
      case 'highway':
        return Color(0xFF4CAF50);
      case 'mixed':
        return Color(0xFFFF9800);
      default:
        return Colors.grey;
    }
  }

  Widget _buildChartContainer(
    String title,
    Widget chart, {
    double height = 200,
    List<Map<String, dynamic>>? legend,
  }) {
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
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            height: height,
            child: chart,
          ),
          if (legend != null) ...[
            SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: legend.map((item) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: item['color'],
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      item['label'],
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyChart(String message) {
    return Container(
      padding: EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ),
    );
  }
}

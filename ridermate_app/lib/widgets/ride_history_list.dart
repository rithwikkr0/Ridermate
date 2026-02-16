import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/ride.dart';
import '../models/ride_filter.dart';
import '../services/ride_history_service.dart';
import 'ride_detail.dart';
import 'ride_filter_widget.dart';

class RideHistoryList extends StatefulWidget {
  final String userId;

  const RideHistoryList({Key? key, required this.userId}) : super(key: key);

  @override
  _RideHistoryListState createState() => _RideHistoryListState();
}

class _RideHistoryListState extends State<RideHistoryList> {
  final RideHistoryService _service = RideHistoryService();
  List<Ride> _allRides = [];
  List<Ride> _filteredRides = [];
  RideFilter _filter = RideFilter();
  SortOption _sortOption = SortOption.dateNewest;
  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadRides();
  }

  Future<void> _loadRides() async {
    setState(() => _isLoading = true);
    try {
      final rides = await _service.getUserRides(widget.userId);
      setState(() {
        _allRides = rides;
        _filteredRides = rides;
        _isLoading = false;
      });
      _applyFilterAndSort();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading rides: $e')),
      );
    }
  }

  Future<void> _applyFilterAndSort() async {
    final filtered = await _service.filterAndSortRides(
      _allRides,
      _filter,
      _sortOption,
    );
    setState(() {
      _filteredRides = filtered;
    });
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RideFilterWidget(
        currentFilter: _filter,
        onApply: (newFilter) {
          setState(() {
            _filter = newFilter;
          });
          _applyFilterAndSort();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: Text(
          'Ride History',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterDialog,
          ),
          PopupMenuButton<SortOption>(
            icon: Icon(Icons.sort, color: Colors.white),
            onSelected: (option) {
              setState(() {
                _sortOption = option;
              });
              _applyFilterAndSort();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: SortOption.dateNewest,
                child: Text('Date (Newest)'),
              ),
              PopupMenuItem(
                value: SortOption.dateOldest,
                child: Text('Date (Oldest)'),
              ),
              PopupMenuItem(
                value: SortOption.distanceLongest,
                child: Text('Distance (Longest)'),
              ),
              PopupMenuItem(
                value: SortOption.distanceShortest,
                child: Text('Distance (Shortest)'),
              ),
              PopupMenuItem(
                value: SortOption.safetyBest,
                child: Text('Safety (Best)'),
              ),
              PopupMenuItem(
                value: SortOption.safetyWorst,
                child: Text('Safety (Worst)'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _filteredRides.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    if (_filter.hasActiveFilters) _buildFilterBadge(),
                    _buildQuickStats(),
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.all(16),
                        itemCount: _filteredRides.length,
                        itemBuilder: (context, index) {
                          return _buildRideCard(_filteredRides[index]);
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_bike, size: 80, color: Colors.grey),
          SizedBox(height: 20),
          Text(
            'No rides found',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          SizedBox(height: 10),
          Text(
            'Start riding to see your history',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBadge() {
    return Container(
      padding: EdgeInsets.all(12),
      color: Color(0xFF0066FF).withOpacity(0.2),
      child: Row(
        children: [
          Icon(Icons.filter_alt, color: Color(0xFF0066FF), size: 20),
          SizedBox(width: 8),
          Text(
            'Filters applied',
            style: TextStyle(color: Color(0xFF0066FF)),
          ),
          Spacer(),
          TextButton(
            onPressed: () {
              setState(() {
                _filter = RideFilter();
              });
              _applyFilterAndSort();
            },
            child: Text('Clear'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final totalDistance = _filteredRides.fold<double>(0, (sum, r) => sum + r.distance);
    final avgSafety = _filteredRides.isEmpty
        ? 0.0
        : _filteredRides.fold<double>(0, (sum, r) => sum + r.safetyScore) /
            _filteredRides.length;

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Rides', '${_filteredRides.length}'),
          _buildStatItem('Distance', '${totalDistance.toStringAsFixed(1)} km'),
          _buildStatItem('Avg Safety', '${avgSafety.toStringAsFixed(1)}'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: Color(0xFF0066FF),
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
    );
  }

  Widget _buildRideCard(Ride ride) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('HH:mm');

    Color safetyColor = ride.safetyScore >= 80
        ? Colors.green
        : ride.safetyScore >= 60
            ? Colors.orange
            : Colors.red;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RideDetail(ride: ride),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[800]!, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateFormat.format(ride.startTime),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: safetyColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.shield, color: safetyColor, size: 16),
                      SizedBox(width: 4),
                      Text(
                        '${ride.safetyScore.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: safetyColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.schedule, color: Colors.grey, size: 16),
                SizedBox(width: 4),
                Text(
                  '${timeFormat.format(ride.startTime)} - ${timeFormat.format(ride.endTime)}',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                SizedBox(width: 12),
                Icon(Icons.wb_sunny, color: Colors.grey, size: 16),
                SizedBox(width: 4),
                Text(
                  ride.timeOfDay,
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetric(
                    Icons.route, ride.formattedDistance, 'Distance'),
                _buildMetric(Icons.timer, ride.formattedDuration, 'Duration'),
                _buildMetric(Icons.speed,
                    '${ride.avgSpeed.toStringAsFixed(1)} km/h', 'Avg Speed'),
              ],
            ),
            if (ride.terrain.isNotEmpty || ride.memoryCount > 0)
              SizedBox(height: 8),
            if (ride.terrain.isNotEmpty || ride.memoryCount > 0)
              Row(
                children: [
                  if (ride.terrain.isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        ride.terrain,
                        style: TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                    ),
                  if (ride.memoryCount > 0) SizedBox(width: 8),
                  if (ride.memoryCount > 0)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.photo_camera,
                              color: Colors.grey, size: 12),
                          SizedBox(width: 4),
                          Text(
                            '${ride.memoryCount}',
                            style: TextStyle(color: Colors.grey, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Color(0xFF0066FF), size: 20),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey, fontSize: 10),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

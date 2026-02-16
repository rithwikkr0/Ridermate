import 'package:flutter/material.dart';
import '../models/ride_filter.dart';

class RideFilterWidget extends StatefulWidget {
  final RideFilter currentFilter;
  final Function(RideFilter) onApply;

  const RideFilterWidget({
    super.key,
    required this.currentFilter,
    required this.onApply,
  });

  @override
  _RideFilterWidgetState createState() => _RideFilterWidgetState();
}

class _RideFilterWidgetState extends State<RideFilterWidget> {
  late DateTime? _startDate;
  late DateTime? _endDate;
  late double? _minDistance;
  late double? _maxDistance;
  late double? _minSafetyScore;
  late double? _maxSafetyScore;
  late String? _timeOfDay;
  late String? _terrain;
  
  final TextEditingController _minDistanceController = TextEditingController();
  final TextEditingController _maxDistanceController = TextEditingController();
  final TextEditingController _minSafetyController = TextEditingController();
  final TextEditingController _maxSafetyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startDate = widget.currentFilter.startDate;
    _endDate = widget.currentFilter.endDate;
    _minDistance = widget.currentFilter.minDistance;
    _maxDistance = widget.currentFilter.maxDistance;
    _minSafetyScore = widget.currentFilter.minSafetyScore;
    _maxSafetyScore = widget.currentFilter.maxSafetyScore;
    _timeOfDay = widget.currentFilter.timeOfDay;
    _terrain = widget.currentFilter.terrain;
    
    // Initialize controllers with current values
    _minDistanceController.text = _minDistance?.toString() ?? '';
    _maxDistanceController.text = _maxDistance?.toString() ?? '';
    _minSafetyController.text = _minSafetyScore?.toString() ?? '';
    _maxSafetyController.text = _maxSafetyScore?.toString() ?? '';
  }

  @override
  void dispose() {
    _minDistanceController.dispose();
    _maxDistanceController.dispose();
    _minSafetyController.dispose();
    _maxSafetyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Rides',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          SizedBox(height: 20),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Date Range'),
                Row(
                  children: [
                    Expanded(
                      child: _buildDateButton(
                        'Start Date',
                        _startDate,
                        () => _selectDate(context, true),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildDateButton(
                        'End Date',
                        _endDate,
                        () => _selectDate(context, false),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                _buildSectionTitle('Distance (km)'),
                Row(
                  children: [
                    Expanded(
                      child: _buildNumberField(
                        'Min',
                        _minDistanceController,
                        (value) => setState(() => _minDistance = value),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildNumberField(
                        'Max',
                        _maxDistanceController,
                        (value) => setState(() => _maxDistance = value),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                _buildSectionTitle('Safety Score'),
                Row(
                  children: [
                    Expanded(
                      child: _buildNumberField(
                        'Min',
                        _minSafetyController,
                        (value) => setState(() => _minSafetyScore = value),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildNumberField(
                        'Max',
                        _maxSafetyController,
                        (value) => setState(() => _maxSafetyScore = value),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                _buildSectionTitle('Time of Day'),
                _buildChipGroup(
                  ['morning', 'afternoon', 'evening', 'night'],
                  _timeOfDay,
                  (value) => setState(() => _timeOfDay = value),
                ),
                SizedBox(height: 20),
                _buildSectionTitle('Terrain'),
                _buildChipGroup(
                  ['urban', 'highway', 'mixed'],
                  _terrain,
                  (value) => setState(() => _terrain = value),
                ),
                SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _clearFilters,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(color: Colors.grey),
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text('Clear All'),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _applyFilters,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF0066FF),
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text('Apply Filters'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDateButton(String label, DateTime? date, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[700]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            SizedBox(height: 4),
            Text(
              date != null
                  ? '${date.day}/${date.month}/${date.year}'
                  : 'Not set',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberField(
      String label, TextEditingController controller, Function(double?) onChanged) {
    return TextField(
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[850],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[700]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[700]!),
        ),
      ),
      keyboardType: TextInputType.number,
      controller: controller,
      onChanged: (text) {
        onChanged(text.isEmpty ? null : double.tryParse(text));
      },
    );
  }

  Widget _buildChipGroup(
      List<String> options, String? selected, Function(String?) onChanged) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = option == selected;
        return ChoiceChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (selected) {
            onChanged(selected ? option : null);
          },
          selectedColor: Color(0xFF0066FF),
          backgroundColor: Colors.grey[850],
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
          ),
        );
      }).toList(),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark(),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _minDistance = null;
      _maxDistance = null;
      _minSafetyScore = null;
      _maxSafetyScore = null;
      _timeOfDay = null;
      _terrain = null;
    });
    _minDistanceController.clear();
    _maxDistanceController.clear();
    _minSafetyController.clear();
    _maxSafetyController.clear();
    widget.onApply(RideFilter());
    Navigator.pop(context);
  }

  void _applyFilters() {
    final filter = RideFilter(
      startDate: _startDate,
      endDate: _endDate,
      minDistance: _minDistance,
      maxDistance: _maxDistance,
      minSafetyScore: _minSafetyScore,
      maxSafetyScore: _maxSafetyScore,
      timeOfDay: _timeOfDay,
      terrain: _terrain,
    );
    widget.onApply(filter);
    Navigator.pop(context);
  }
}

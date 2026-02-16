import 'package:flutter/material.dart';
import '../models/live_location.dart';
import '../services/location_service.dart';

/// Widget to display live location map with friend markers
class LiveLocationMapWidget extends StatefulWidget {
  final LocationService locationService;
  final String currentUserId;

  const LiveLocationMapWidget({
    Key? key,
    required this.locationService,
    required this.currentUserId,
  }) : super(key: key);

  @override
  _LiveLocationMapWidgetState createState() => _LiveLocationMapWidgetState();
}

class _LiveLocationMapWidgetState extends State<LiveLocationMapWidget> {
  Map<String, LiveLocation> _friendLocations = {};
  LiveLocation? _myLocation;

  @override
  void initState() {
    super.initState();
    _loadLocations();

    // Listen to location updates
    widget.locationService.locationsStream.listen((locations) {
      if (mounted) {
        setState(() {
          _friendLocations = locations;
        });
      }
    });

    widget.locationService.myLocationStream.listen((location) {
      if (mounted) {
        setState(() {
          _myLocation = location;
        });
      }
    });
  }

  Future<void> _loadLocations() async {
    try {
      final locations = await widget.locationService.getFriendLocations();
      setState(() {
        _friendLocations = locations;
      });
    } catch (e) {
      print('Failed to load locations: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // Map placeholder - in production, use google_maps_flutter
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map,
                    size: 64,
                    color: Colors.grey[700],
                  ),
                  SizedBox(height: 16),
                  Text(
                    '🗺️ Live Map',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Google Maps integration would go here',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Friend markers overlay (simulated)
          if (_friendLocations.isNotEmpty || _myLocation != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Active Locations',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    if (_myLocation != null) ...[
                      _buildLocationItem(
                        name: 'You',
                        location: _myLocation!,
                        color: Color(0xFF4CAF50),
                        isMe: true,
                      ),
                      if (_friendLocations.isNotEmpty) SizedBox(height: 8),
                    ],
                    ..._friendLocations.entries.map((entry) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: _buildLocationItem(
                          name: entry.value.userName,
                          location: entry.value,
                          color: Color(0xFF0066FF),
                          isMe: false,
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),

          // Empty state
          if (_friendLocations.isEmpty && _myLocation == null)
            Center(
              child: Container(
                margin: EdgeInsets.all(40),
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_off,
                      size: 48,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No active locations',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Enable location sharing to see\nyour friends on the map',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLocationItem({
    required String name,
    required LiveLocation location,
    required Color color,
    required bool isMe,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isMe ? Icons.person : Icons.person_pin_circle,
              color: Colors.white,
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    if (location.speed != null) ...[
                      Icon(Icons.speed, size: 12, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        location.formattedSpeed,
                        style: TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                      SizedBox(width: 12),
                    ],
                    Icon(Icons.location_on, size: 12, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}',
                      style: TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (location.isStale)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Stale',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Color(0xFF4CAF50),
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}

/// Simulated map marker for friend location
class FriendMarker extends StatelessWidget {
  final LiveLocation location;
  final Color color;

  const FriendMarker({
    Key? key,
    required this.location,
    this.color = const Color(0xFF0066FF),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            children: [
              Text(
                location.userName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (location.speed != null)
                Text(
                  location.formattedSpeed,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 8,
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 4),
        Icon(
          Icons.location_on,
          color: color,
          size: 32,
        ),
      ],
    );
  }
}

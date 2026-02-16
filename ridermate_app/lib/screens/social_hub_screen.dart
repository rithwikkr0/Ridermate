import 'package:flutter/material.dart';
import '../services/friend_service.dart';
import '../services/ride_room_service.dart';
import '../services/location_service.dart';
import '../widgets/friends_list_widget.dart';
import '../widgets/live_location_map_widget.dart';
import '../widgets/location_sharing_toggle.dart';
import '../widgets/friend_requests_widget.dart';
import 'friends_screen.dart';
import 'ride_rooms_screen.dart';

/// Social hub screen combining friends and location features
class SocialHubScreen extends StatefulWidget {
  final FriendService friendService;
  final RideRoomService roomService;
  final LocationService locationService;
  final String currentUserId;
  final String currentUserName;

  const SocialHubScreen({
    Key? key,
    required this.friendService,
    required this.roomService,
    required this.locationService,
    required this.currentUserId,
    required this.currentUserName,
  }) : super(key: key);

  @override
  _SocialHubScreenState createState() => _SocialHubScreenState();
}

class _SocialHubScreenState extends State<SocialHubScreen> {
  int _requestCount = 0;

  @override
  void initState() {
    super.initState();
    _updateRequestCount();

    widget.friendService.requestsStream.listen((requests) {
      if (mounted) {
        setState(() {
          _requestCount = requests
              .where((r) => r.receiverId == widget.currentUserId)
              .length;
        });
      }
    });
  }

  Future<void> _updateRequestCount() async {
    try {
      final requests = await widget.friendService
          .getPendingRequests(widget.currentUserId);
      if (mounted) {
        setState(() {
          _requestCount = requests.length;
        });
      }
    } catch (e) {
      // Handle silently
    }
  }

  void _navigateToFriends() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FriendsScreen(
          friendService: widget.friendService,
          currentUserId: widget.currentUserId,
        ),
      ),
    );
  }

  void _navigateToRooms() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RideRoomsScreen(
          roomService: widget.roomService,
          currentUserId: widget.currentUserId,
          currentUserName: widget.currentUserName,
        ),
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
          'Social',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_requestCount > 0)
            Stack(
              children: [
                IconButton(
                  icon: Icon(Icons.notifications),
                  onPressed: _navigateToFriends,
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Center(
                      child: Text(
                        _requestCount > 9 ? '9+' : '$_requestCount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location sharing toggle
            Padding(
              padding: EdgeInsets.all(16),
              child: LocationSharingToggle(
                locationService: widget.locationService,
                currentUserId: widget.currentUserId,
                currentUserName: widget.currentUserName,
              ),
            ),

            // Live map
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Live Locations',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    height: 300,
                    child: LiveLocationMapWidget(
                      locationService: widget.locationService,
                      currentUserId: widget.currentUserId,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Quick actions
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Actions',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickAction(
                          icon: Icons.people,
                          label: 'Friends',
                          color: Color(0xFF0066FF),
                          onTap: _navigateToFriends,
                          badge: _requestCount > 0 ? _requestCount : null,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickAction(
                          icon: Icons.groups,
                          label: 'Ride Rooms',
                          color: Color(0xFF4CAF50),
                          onTap: _navigateToRooms,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Friends preview
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Friends',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: _navigateToFriends,
                    child: Text('See All'),
                  ),
                ],
              ),
            ),
            Container(
              height: 200,
              child: FriendsListWidget(
                friendService: widget.friendService,
                currentUserId: widget.currentUserId,
              ),
            ),

            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    int? badge,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 2),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                Icon(icon, color: color, size: 48),
                SizedBox(height: 12),
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
            if (badge != null)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                  child: Center(
                    child: Text(
                      badge > 9 ? '9+' : '$badge',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

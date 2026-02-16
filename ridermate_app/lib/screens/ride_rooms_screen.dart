import 'package:flutter/material.dart';
import 'dart:async';
import '../models/ride_room.dart';
import '../services/ride_room_service.dart';
import '../widgets/create_ride_room_widget.dart';
import '../widgets/ride_room_widget.dart';

/// Screen for managing ride rooms
class RideRoomsScreen extends StatefulWidget {
  final RideRoomService roomService;
  final String currentUserId;
  final String currentUserName;

  const RideRoomsScreen({
    Key? key,
    required this.roomService,
    required this.currentUserId,
    required this.currentUserName,
  }) : super(key: key);

  @override
  _RideRoomsScreenState createState() => _RideRoomsScreenState();
}

class _RideRoomsScreenState extends State<RideRoomsScreen> {
  List<RideRoom> _rooms = [];
  bool _isLoading = true;
  String? _errorMessage;
  RideRoom? _activeRoom;
  
  StreamSubscription<List<RideRoom>>? _roomsSubscription;
  StreamSubscription<RideRoom?>? _activeRoomSubscription;

  @override
  void initState() {
    super.initState();
    _loadRooms();

    // Listen to room updates
    _roomsSubscription = widget.roomService.roomsStream.listen((rooms) {
      if (mounted) {
        setState(() {
          _rooms = rooms;
        });
      }
    });

    _activeRoomSubscription = widget.roomService.activeRoomStream.listen((room) {
      if (mounted) {
        setState(() {
          _activeRoom = room;
        });
      }
    });
  }

  @override
  void dispose() {
    _roomsSubscription?.cancel();
    _activeRoomSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadRooms() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // In a real app, this would fetch from API
    await Future.delayed(Duration(milliseconds: 500));

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _createRoom() async {
    final room = await showModalBottomSheet<RideRoom>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => CreateRideRoomWidget(
        roomService: widget.roomService,
        currentUserId: widget.currentUserId,
        currentUserName: widget.currentUserName,
      ),
    );

    if (room != null) {
      _openRoom(room);
    }
  }

  void _openRoom(RideRoom room) {
    widget.roomService.setActiveRoom(room);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RideRoomWidget(
          room: room,
          roomService: widget.roomService,
          currentUserId: widget.currentUserId,
          onLeave: () {
            widget.roomService.setActiveRoom(null);
          },
        ),
      ),
    );
  }

  Future<void> _joinRoomByCode() async {
    final codeController = TextEditingController();

    final code = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          'Join Private Room',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: codeController,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Invite Code',
            labelStyle: TextStyle(color: Colors.grey),
            hintText: 'Enter 6-character code',
            hintStyle: TextStyle(color: Colors.grey[700]),
            filled: true,
            fillColor: Colors.grey[800],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          textCapitalization: TextCapitalization.characters,
          maxLength: 6,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, codeController.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF0066FF),
            ),
            child: Text('Join'),
          ),
        ],
      ),
    );

    if (code != null && code.isNotEmpty) {
      // TODO: Implement join by code
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Joining room with code: $code')),
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
          'Ride Rooms',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.vpn_key),
            onPressed: _joinRoomByCode,
            tooltip: 'Join by code',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createRoom,
        backgroundColor: Color(0xFF0066FF),
        icon: Icon(Icons.add),
        label: Text('Create Room'),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: Color(0xFF0066FF)),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRooms,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Show active room if exists
    if (_activeRoom != null) {
      return _buildActiveRoomBanner();
    }

    // Show available rooms
    if (_rooms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.groups, size: 64, color: Colors.grey[700]),
            SizedBox(height: 16),
            Text(
              'No active rooms',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Create a room to ride with friends',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRooms,
      color: Color(0xFF0066FF),
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _rooms.length,
        itemBuilder: (context, index) {
          final room = _rooms[index];
          return _buildRoomCard(room);
        },
      ),
    );
  }

  Widget _buildActiveRoomBanner() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF45a049)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, size: 64, color: Colors.white),
          SizedBox(height: 16),
          Text(
            'You\'re in a room!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            _activeRoom!.name,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _openRoom(_activeRoom!),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFF4CAF50),
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Open Room',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomCard(RideRoom room) {
    final isInRoom = room.participants
        .any((p) => p.userId == widget.currentUserId);

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: isInRoom ? () => _openRoom(room) : null,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        room.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: room.isPublic
                            ? Color(0xFF4CAF50).withOpacity(0.2)
                            : Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            room.isPublic ? Icons.public : Icons.lock,
                            size: 12,
                            color: room.isPublic
                                ? Color(0xFF4CAF50)
                                : Colors.orange,
                          ),
                          SizedBox(width: 4),
                          Text(
                            room.isPublic ? 'Public' : 'Private',
                            style: TextStyle(
                              color: room.isPublic
                                  ? Color(0xFF4CAF50)
                                  : Colors.orange,
                              fontSize: 10,
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
                    Icon(Icons.person, size: 14, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      'Host: ${room.hostName}',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.people, size: 14, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            '${room.participantCount}/${room.maxCapacity}',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    if (room.isFull)
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'FULL',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (isInRoom)
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Color(0xFF0066FF).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'JOINED',
                          style: TextStyle(
                            color: Color(0xFF0066FF),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

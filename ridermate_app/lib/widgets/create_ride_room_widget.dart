import 'package:flutter/material.dart';
import '../models/ride_room.dart';
import '../services/ride_room_service.dart';

/// Widget for creating a new ride room
class CreateRideRoomWidget extends StatefulWidget {
  final RideRoomService roomService;
  final String currentUserId;
  final String currentUserName;

  const CreateRideRoomWidget({
    Key? key,
    required this.roomService,
    required this.currentUserId,
    required this.currentUserName,
  }) : super(key: key);

  @override
  _CreateRideRoomWidgetState createState() => _CreateRideRoomWidgetState();
}

class _CreateRideRoomWidgetState extends State<CreateRideRoomWidget> {
  final TextEditingController _nameController = TextEditingController();
  bool _isPublic = true;
  int _maxCapacity = 5;
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createRoom() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a room name'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      final room = await widget.roomService.createRoom(
        hostId: widget.currentUserId,
        hostName: widget.currentUserName,
        name: _nameController.text.trim(),
        isPublic: _isPublic,
        maxCapacity: _maxCapacity,
      );

      Navigator.pop(context, room);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Room "${room.name}" created'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create room: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isCreating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Create Ride Room',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.grey),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          SizedBox(height: 20),

          // Room name input
          TextField(
            controller: _nameController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Room Name',
              labelStyle: TextStyle(color: Colors.grey),
              hintText: 'e.g., Morning City Ride',
              hintStyle: TextStyle(color: Colors.grey[700]),
              filled: true,
              fillColor: Colors.grey[800],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixIcon: Icon(Icons.label, color: Colors.grey),
            ),
          ),

          SizedBox(height: 20),

          // Privacy toggle
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Room Privacy',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _isPublic ? 'Anyone can join' : 'Invite code required',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _buildPrivacyButton('Public', true),
                    SizedBox(width: 8),
                    _buildPrivacyButton('Private', false),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Capacity selector
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Max Participants: $_maxCapacity',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                Slider(
                  value: _maxCapacity.toDouble(),
                  min: 2,
                  max: 20,
                  divisions: 18,
                  activeColor: Color(0xFF0066FF),
                  inactiveColor: Colors.grey[700],
                  label: '$_maxCapacity',
                  onChanged: (value) {
                    setState(() {
                      _maxCapacity = value.toInt();
                    });
                  },
                ),
              ],
            ),
          ),

          SizedBox(height: 24),

          // Create button
          ElevatedButton(
            onPressed: _isCreating ? null : _createRoom,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF0066FF),
              disabledBackgroundColor: Colors.grey[700],
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isCreating
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Create Room',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),

          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }

  Widget _buildPrivacyButton(String label, bool isPublic) {
    final isSelected = _isPublic == isPublic;
    return GestureDetector(
      onTap: () {
        setState(() {
          _isPublic = isPublic;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF0066FF) : Colors.grey[700],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

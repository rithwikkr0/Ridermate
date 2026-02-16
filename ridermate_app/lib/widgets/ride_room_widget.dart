import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/ride_room.dart';
import '../services/ride_room_service.dart';

/// Widget to display and manage a ride room
class RideRoomWidget extends StatefulWidget {
  final RideRoom room;
  final RideRoomService roomService;
  final String currentUserId;
  final VoidCallback? onLeave;

  const RideRoomWidget({
    Key? key,
    required this.room,
    required this.roomService,
    required this.currentUserId,
    this.onLeave,
  }) : super(key: key);

  @override
  _RideRoomWidgetState createState() => _RideRoomWidgetState();
}

class _RideRoomWidgetState extends State<RideRoomWidget> {
  late RideRoom _room;
  final TextEditingController _chatController = TextEditingController();
  List<ChatMessage> _messages = [];
  bool _showChat = false;

  @override
  void initState() {
    super.initState();
    _room = widget.room;
    _loadMessages();
    
    // Listen to room updates
    widget.roomService.activeRoomStream.listen((room) {
      if (room != null && room.id == _room.id && mounted) {
        setState(() {
          _room = room;
        });
      }
    });
    
    // Listen to messages
    widget.roomService.messagesStream.listen((messages) {
      if (mounted) {
        setState(() {
          _messages = messages;
        });
      }
    });
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  void _loadMessages() {
    final messages = widget.roomService.getMessages(_room.id);
    setState(() {
      _messages = messages;
    });
  }

  Future<void> _leaveRoom() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Leave Room', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to leave this room?',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Leave'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await widget.roomService.leaveRoom(_room.id, widget.currentUserId);
        widget.onLeave?.call();
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to leave room'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _startRide() async {
    try {
      await widget.roomService.startRide(_room.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ride started!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to start ride'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _sendMessage() async {
    if (_chatController.text.trim().isEmpty) return;

    try {
      await widget.roomService.sendMessage(
        roomId: _room.id,
        senderId: widget.currentUserId,
        senderName: 'Current User', // Get from auth in real app
        message: _chatController.text.trim(),
      );
      _chatController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send message'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _copyInviteCode() {
    if (_room.inviteCode != null) {
      Clipboard.setData(ClipboardData(text: _room.inviteCode!));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invite code copied to clipboard'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isHost = _room.hostId == widget.currentUserId;
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_room.name, style: TextStyle(fontSize: 18)),
            Text(
              '${_room.participantCount}/${_room.maxCapacity} participants',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          if (_showChat)
            IconButton(
              icon: Icon(Icons.people),
              onPressed: () => setState(() => _showChat = false),
              tooltip: 'Show participants',
            )
          else
            IconButton(
              icon: Icon(Icons.chat),
              onPressed: () => setState(() => _showChat = true),
              tooltip: 'Show chat',
            ),
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: _leaveRoom,
            tooltip: 'Leave room',
          ),
        ],
      ),
      body: Column(
        children: [
          // Room info card
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0066FF), Color(0xFF004499)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Host: ${_room.hostName}',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                _room.isPublic ? Icons.public : Icons.lock,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                _room.isPublic ? 'Public' : 'Private',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (!_room.isPublic && _room.inviteCode != null)
                      GestureDetector(
                        onTap: _copyInviteCode,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Text(
                                _room.inviteCode!,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.copy, color: Colors.white, size: 16),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                if (isHost && _room.status == RoomStatus.waiting) ...[
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _startRide,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4CAF50),
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.play_arrow),
                        SizedBox(width: 8),
                        Text('Start Ride', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ],
                if (_room.status == RoomStatus.active)
                  Container(
                    margin: EdgeInsets.only(top: 12),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '🚴 Ride In Progress',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Content area (participants or chat)
          Expanded(
            child: _showChat ? _buildChatView() : _buildParticipantsView(),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantsView() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16),
      itemCount: _room.participants.length,
      itemBuilder: (context, index) {
        final participant = _room.participants[index];
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
            border: participant.isHost
                ? Border.all(color: Color(0xFFFFD700), width: 2)
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: participant.isHost
                      ? Color(0xFFFFD700)
                      : Color(0xFF0066FF),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    participant.name[0].toUpperCase(),
                    style: TextStyle(
                      color: participant.isHost ? Colors.black : Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          participant.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (participant.isHost) ...[
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Color(0xFFFFD700).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'HOST',
                              style: TextStyle(
                                color: Color(0xFFFFD700),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      '@${participant.username}',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
              if (participant.isReady)
                Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChatView() {
    return Column(
      children: [
        Expanded(
          child: _messages.isEmpty
              ? Center(
                  child: Text(
                    'No messages yet\nSay hi! 👋',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    final isMe = message.senderId == widget.currentUserId;
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.only(bottom: 12),
                        padding: EdgeInsets.all(12),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                        ),
                        decoration: BoxDecoration(
                          color: isMe ? Color(0xFF0066FF) : Colors.grey[800],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isMe)
                              Text(
                                message.senderName,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            SizedBox(height: 4),
                            Text(
                              message.message,
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        Container(
          padding: EdgeInsets.all(16),
          color: Colors.grey[900],
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[800],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF0066FF),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.send, color: Colors.white),
                  onPressed: _sendMessage,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

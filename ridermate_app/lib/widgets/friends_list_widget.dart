import 'package:flutter/material.dart';
import 'dart:async';
import '../models/friend.dart';
import '../services/friend_service.dart';

/// Widget to display list of friends
class FriendsListWidget extends StatefulWidget {
  final FriendService friendService;
  final String currentUserId;

  const FriendsListWidget({
    Key? key,
    required this.friendService,
    required this.currentUserId,
  }) : super(key: key);

  @override
  _FriendsListWidgetState createState() => _FriendsListWidgetState();
}

class _FriendsListWidgetState extends State<FriendsListWidget> {
  List<Friend> _friends = [];
  bool _isLoading = true;
  String? _errorMessage;
  StreamSubscription<List<Friend>>? _friendsSubscription;

  @override
  void initState() {
    super.initState();
    _loadFriends();
    
    // Listen to friend updates
    _friendsSubscription = widget.friendService.friendsStream.listen((friends) {
      if (mounted) {
        setState(() {
          _friends = friends;
        });
      }
    });
  }

  @override
  void dispose() {
    _friendsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadFriends() async {
    try {
      final friends = await widget.friendService.getFriends(widget.currentUserId);
      setState(() {
        _friends = friends;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load friends';
        _isLoading = false;
      });
    }
  }

  Future<void> _removeFriend(Friend friend) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          'Remove Friend',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to remove ${friend.friendName} from your friends?',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await widget.friendService.removeFriend(friend.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${friend.friendName} removed from friends'),
            backgroundColor: Colors.orange,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove friend'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
              onPressed: _loadFriends,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_friends.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[700]),
            SizedBox(height: 16),
            Text(
              'No friends yet',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Search for users to add as friends',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      color: Colors.black,
      child: RefreshIndicator(
        onRefresh: _loadFriends,
        color: Color(0xFF0066FF),
        child: ListView.builder(
          itemCount: _friends.length,
          itemBuilder: (context, index) {
            final friend = _friends[index];
            return _buildFriendCard(friend);
          },
        ),
      ),
    );
  }

  Widget _buildFriendCard(Friend friend) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: friend.isOnline
            ? Border.all(color: Color(0xFF4CAF50), width: 2)
            : null,
      ),
      child: Row(
        children: [
          // Avatar with online indicator
          Stack(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Color(0xFF0066FF),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    friend.friendName[0].toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (friend.isOnline)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey[900]!, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(width: 12),

          // Friend info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  friend.friendName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '@${friend.friendUsername}',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    if (friend.isOnline) ...[
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Color(0xFF4CAF50).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Online',
                          style: TextStyle(
                            color: Color(0xFF4CAF50),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Actions
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.grey),
            color: Colors.grey[900],
            onSelected: (value) {
              if (value == 'remove') {
                _removeFriend(friend);
              } else if (value == 'message') {
                // TODO: Open chat
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Chat feature coming soon')),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'message',
                child: Row(
                  children: [
                    Icon(Icons.message, color: Color(0xFF0066FF), size: 20),
                    SizedBox(width: 8),
                    Text('Message', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'remove',
                child: Row(
                  children: [
                    Icon(Icons.person_remove, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('Remove Friend', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

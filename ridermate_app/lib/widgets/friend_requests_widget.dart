import 'package:flutter/material.dart';
import '../models/friend.dart';
import '../services/friend_service.dart';

/// Widget to display and manage friend requests
class FriendRequestsWidget extends StatefulWidget {
  final FriendService friendService;
  final String currentUserId;

  const FriendRequestsWidget({
    Key? key,
    required this.friendService,
    required this.currentUserId,
  }) : super(key: key);

  @override
  _FriendRequestsWidgetState createState() => _FriendRequestsWidgetState();
}

class _FriendRequestsWidgetState extends State<FriendRequestsWidget> {
  List<FriendRequest> _requests = [];
  bool _isLoading = true;
  String? _errorMessage;
  final Set<String> _processingIds = {};

  @override
  void initState() {
    super.initState();
    _loadRequests();
    
    // Listen to request updates
    widget.friendService.requestsStream.listen((requests) {
      if (mounted) {
        setState(() {
          _requests = requests.where((r) => 
            r.receiverId == widget.currentUserId && 
            r.status == FriendRequestStatus.pending
          ).toList();
        });
      }
    });
  }

  Future<void> _loadRequests() async {
    try {
      final requests = await widget.friendService.getPendingRequests(widget.currentUserId);
      setState(() {
        _requests = requests;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load requests';
        _isLoading = false;
      });
    }
  }

  Future<void> _acceptRequest(FriendRequest request) async {
    setState(() {
      _processingIds.add(request.id);
    });

    try {
      await widget.friendService.acceptFriendRequest(
        request.id,
        widget.currentUserId,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You are now friends with ${request.senderName}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to accept request'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _processingIds.remove(request.id);
      });
    }
  }

  Future<void> _rejectRequest(FriendRequest request) async {
    setState(() {
      _processingIds.add(request.id);
    });

    try {
      await widget.friendService.rejectFriendRequest(request.id);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Friend request rejected'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to reject request'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _processingIds.remove(request.id);
      });
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
              onPressed: _loadRequests,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey[700]),
            SizedBox(height: 16),
            Text(
              'No pending requests',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      color: Colors.black,
      child: ListView.builder(
        itemCount: _requests.length,
        itemBuilder: (context, index) {
          final request = _requests[index];
          final isProcessing = _processingIds.contains(request.id);
          
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFF0066FF), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Avatar
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Color(0xFF0066FF),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          request.senderName[0].toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),

                    // Sender info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request.senderName,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '@${request.senderUsername}',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Time badge
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _formatTime(request.createdAt),
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 16),

                // Action buttons
                if (isProcessing)
                  Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF0066FF),
                      strokeWidth: 2,
                    ),
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _acceptRequest(request),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF4CAF50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check, size: 18),
                              SizedBox(width: 8),
                              Text('Accept'),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _rejectRequest(request),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.close, size: 18),
                              SizedBox(width: 8),
                              Text('Reject'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}

/// Notification badge widget for friend requests
class FriendRequestBadge extends StatefulWidget {
  final FriendService friendService;
  final String currentUserId;
  final VoidCallback onTap;

  const FriendRequestBadge({
    Key? key,
    required this.friendService,
    required this.currentUserId,
    required this.onTap,
  }) : super(key: key);

  @override
  _FriendRequestBadgeState createState() => _FriendRequestBadgeState();
}

class _FriendRequestBadgeState extends State<FriendRequestBadge> {
  int _requestCount = 0;

  @override
  void initState() {
    super.initState();
    _updateCount();
    
    widget.friendService.requestsStream.listen((requests) {
      if (mounted) {
        setState(() {
          _requestCount = requests.where((r) => 
            r.receiverId == widget.currentUserId && 
            r.status == FriendRequestStatus.pending
          ).length;
        });
      }
    });
  }

  Future<void> _updateCount() async {
    try {
      final requests = await widget.friendService.getPendingRequests(widget.currentUserId);
      if (mounted) {
        setState(() {
          _requestCount = requests.length;
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        children: [
          Icon(
            Icons.people,
            color: Colors.white,
            size: 28,
          ),
          if (_requestCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                child: Center(
                  child: Text(
                    _requestCount > 9 ? '9+' : '$_requestCount',
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
    );
  }
}

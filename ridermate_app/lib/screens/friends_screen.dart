import 'package:flutter/material.dart';
import '../services/friend_service.dart';
import '../widgets/friend_search_widget.dart';
import '../widgets/friends_list_widget.dart';
import '../widgets/friend_requests_widget.dart';

/// Screen for managing friends
class FriendsScreen extends StatefulWidget {
  final FriendService friendService;
  final String currentUserId;

  const FriendsScreen({
    Key? key,
    required this.friendService,
    required this.currentUserId,
  }) : super(key: key);

  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _requestCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _updateRequestCount();

    // Listen to request updates
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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _updateRequestCount() async {
    try {
      final requests =
          await widget.friendService.getPendingRequests(widget.currentUserId);
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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: Text(
          'Friends',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Color(0xFF0066FF),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(
              icon: Icon(Icons.people),
              text: 'My Friends',
            ),
            Tab(
              icon: Icon(Icons.search),
              text: 'Search',
            ),
            Tab(
              icon: Stack(
                children: [
                  Icon(Icons.notifications),
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
              text: 'Requests',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          FriendsListWidget(
            friendService: widget.friendService,
            currentUserId: widget.currentUserId,
          ),
          FriendSearchWidget(
            friendService: widget.friendService,
            currentUserId: widget.currentUserId,
          ),
          FriendRequestsWidget(
            friendService: widget.friendService,
            currentUserId: widget.currentUserId,
          ),
        ],
      ),
    );
  }
}

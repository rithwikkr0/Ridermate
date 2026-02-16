import 'package:flutter/material.dart';
import '../models/memory.dart';
import '../services/memory_service.dart';
import '../widgets/memory_card.dart';
import 'memory_detail_screen.dart';

class MemoryFeedScreen extends StatefulWidget {
  final String currentUserId;
  final List<String> friendIds;

  const MemoryFeedScreen({
    Key? key,
    required this.currentUserId,
    required this.friendIds,
  }) : super(key: key);

  @override
  _MemoryFeedScreenState createState() => _MemoryFeedScreenState();
}

class _MemoryFeedScreenState extends State<MemoryFeedScreen> {
  final _memoryService = MemoryService();
  List<MemoryModel> _memories = [];
  bool _isLoading = true;
  Set<String> _likedMemories = {};

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  Future<void> _loadFeed() async {
    setState(() => _isLoading = true);
    try {
      final memories = await _memoryService.getFriendsMemories(
        currentUserId: widget.currentUserId,
        friendIds: widget.friendIds,
      );

      // Load liked status
      for (var memory in memories) {
        final isLiked = await _memoryService.hasLiked(
          memoryId: memory.memoryId,
          userId: widget.currentUserId,
        );
        if (isLiked) {
          _likedMemories.add(memory.memoryId);
        }
      }

      setState(() {
        _memories = memories;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load feed: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleLike(MemoryModel memory) async {
    try {
      final isLiked = await _memoryService.toggleLike(
        memoryId: memory.memoryId,
        userId: widget.currentUserId,
      );

      setState(() {
        if (isLiked) {
          _likedMemories.add(memory.memoryId);
        } else {
          _likedMemories.remove(memory.memoryId);
        }
      });

      _loadFeed();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to like memory: $e')),
      );
    }
  }

  void _navigateToDetail(MemoryModel memory) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MemoryDetailScreen(
          memory: memory,
          currentUserId: widget.currentUserId,
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
        title: const Text('Friends Feed', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _memories.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 80, color: Colors.grey),
                      SizedBox(height: 20),
                      Text(
                        'No memories from friends yet',
                        style: TextStyle(color: Colors.grey, fontSize: 18),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Add friends to see their memories here',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadFeed,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    itemCount: _memories.length,
                    itemBuilder: (context, index) {
                      final memory = _memories[index];
                      return MemoryCard(
                        memory: memory,
                        isLiked: _likedMemories.contains(memory.memoryId),
                        onTap: () => _navigateToDetail(memory),
                        onLike: () => _toggleLike(memory),
                      );
                    },
                  ),
                ),
    );
  }
}

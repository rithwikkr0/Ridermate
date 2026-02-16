import 'package:flutter/material.dart';
import '../models/memory.dart';
import '../services/memory_service.dart';
import '../widgets/memory_card.dart';
import 'memory_detail_screen.dart';
import 'add_memory_screen.dart';

class MemoryGalleryScreen extends StatefulWidget {
  final String userId;
  final String currentUserId;

  const MemoryGalleryScreen({
    Key? key,
    required this.userId,
    required this.currentUserId,
  }) : super(key: key);

  @override
  _MemoryGalleryScreenState createState() => _MemoryGalleryScreenState();
}

class _MemoryGalleryScreenState extends State<MemoryGalleryScreen> {
  final _memoryService = MemoryService();
  List<MemoryModel> _memories = [];
  List<MemoryModel> _filteredMemories = [];
  bool _isLoading = true;
  bool _isGridView = false;
  MemoryVisibility? _filterVisibility;
  Set<String> _likedMemories = {};

  @override
  void initState() {
    super.initState();
    _loadMemories();
  }

  Future<void> _loadMemories() async {
    setState(() => _isLoading = true);
    try {
      final memories = await _memoryService.getUserMemories(
        userId: widget.userId,
        currentUserId: widget.currentUserId,
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
        _filteredMemories = memories;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load memories: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  void _filterMemories(MemoryVisibility? visibility) {
    setState(() {
      _filterVisibility = visibility;
      if (visibility == null) {
        _filteredMemories = _memories;
      } else {
        _filteredMemories = _memories.where((m) => m.visibility == visibility).toList();
      }
    });
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

      // Reload to update counts
      _loadMemories();
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
          onDeleted: _loadMemories,
        ),
      ),
    );
  }

  void _navigateToAddMemory() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMemoryScreen(userId: widget.currentUserId),
      ),
    );

    if (result == true) {
      _loadMemories();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: const Text('Memories', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // View toggle
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view, color: Colors.white),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
          
          // Filter button
          PopupMenuButton<MemoryVisibility?>(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            color: Colors.grey[900],
            onSelected: _filterMemories,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('All', style: TextStyle(color: Colors.white)),
              ),
              ...MemoryVisibility.values.map((visibility) {
                return PopupMenuItem(
                  value: visibility,
                  child: Row(
                    children: [
                      Text(visibility.icon),
                      const SizedBox(width: 8),
                      Text(visibility.displayName, style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                );
              }),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredMemories.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.photo_library, size: 80, color: Colors.grey),
                      const SizedBox(height: 20),
                      const Text(
                        'No memories yet',
                        style: TextStyle(color: Colors.grey, fontSize: 18),
                      ),
                      if (widget.userId == widget.currentUserId) ...[
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: _navigateToAddMemory,
                          icon: const Icon(Icons.add),
                          label: const Text('Create Memory'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0066FF),
                          ),
                        ),
                      ],
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadMemories,
                  child: _isGridView ? _buildGridView() : _buildListView(),
                ),
      floatingActionButton: widget.userId == widget.currentUserId
          ? FloatingActionButton(
              onPressed: _navigateToAddMemory,
              backgroundColor: const Color(0xFF0066FF),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemCount: _filteredMemories.length,
      itemBuilder: (context, index) {
        final memory = _filteredMemories[index];
        return MemoryCard(
          memory: memory,
          isLiked: _likedMemories.contains(memory.memoryId),
          onTap: () => _navigateToDetail(memory),
          onLike: () => _toggleLike(memory),
        );
      },
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.75,
      ),
      itemCount: _filteredMemories.length,
      itemBuilder: (context, index) {
        final memory = _filteredMemories[index];
        return _buildGridItem(memory);
      },
    );
  }

  Widget _buildGridItem(MemoryModel memory) {
    return GestureDetector(
      onTap: () => _navigateToDetail(memory),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                child: Image.network(
                  memory.thumbnailUrl ?? memory.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[800],
                      child: const Icon(Icons.error, color: Colors.red),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    memory.caption,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        memory.visibility.icon,
                        style: const TextStyle(fontSize: 12),
                      ),
                      Row(
                        children: [
                          Icon(
                            _likedMemories.contains(memory.memoryId)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 14,
                            color: _likedMemories.contains(memory.memoryId)
                                ? const Color(0xFFFF6B35)
                                : Colors.grey,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${memory.likeCount}',
                            style: const TextStyle(color: Colors.grey, fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

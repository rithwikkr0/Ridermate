import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../models/memory.dart';
import '../services/memory_service.dart';

class MemoryDetailScreen extends StatefulWidget {
  final MemoryModel memory;
  final String currentUserId;
  final VoidCallback? onDeleted;

  const MemoryDetailScreen({
    Key? key,
    required this.memory,
    required this.currentUserId,
    this.onDeleted,
  }) : super(key: key);

  @override
  _MemoryDetailScreenState createState() => _MemoryDetailScreenState();
}

class _MemoryDetailScreenState extends State<MemoryDetailScreen> {
  final _memoryService = MemoryService();
  late MemoryModel _memory;
  bool _isLiked = false;
  bool _isEditing = false;
  final _captionController = TextEditingController();
  MemoryVisibility? _editVisibility;

  @override
  void initState() {
    super.initState();
    _memory = widget.memory;
    _captionController.text = _memory.caption;
    _editVisibility = _memory.visibility;
    _checkLikedStatus();
    _recordView();
  }

  Future<void> _checkLikedStatus() async {
    final isLiked = await _memoryService.hasLiked(
      memoryId: _memory.memoryId,
      userId: widget.currentUserId,
    );
    setState(() => _isLiked = isLiked);
  }

  Future<void> _recordView() async {
    if (widget.currentUserId != _memory.userId) {
      await _memoryService.recordView(
        memoryId: _memory.memoryId,
        userId: widget.currentUserId,
      );
    }
  }

  Future<void> _toggleLike() async {
    try {
      final isLiked = await _memoryService.toggleLike(
        memoryId: _memory.memoryId,
        userId: widget.currentUserId,
      );

      setState(() {
        _isLiked = isLiked;
        _memory = _memory.copyWith(
          likeCount: _memory.likeCount + (isLiked ? 1 : -1),
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to like memory: $e')),
      );
    }
  }

  Future<void> _deleteMemory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Delete Memory', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to delete this memory? This action cannot be undone.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _memoryService.deleteMemory(_memory.memoryId);
        Navigator.pop(context);
        widget.onDeleted?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Memory deleted')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete memory: $e')),
        );
      }
    }
  }

  Future<void> _updateMemory() async {
    try {
      await _memoryService.updateMemory(
        memoryId: _memory.memoryId,
        caption: _captionController.text,
        visibility: _editVisibility,
      );

      setState(() {
        _memory = _memory.copyWith(
          caption: _captionController.text,
          visibility: _editVisibility,
        );
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Memory updated')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update memory: $e')),
      );
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = widget.currentUserId == _memory.userId;

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          // App bar with image
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'memory_${_memory.memoryId}',
                child: CachedNetworkImage(
                  imageUrl: _memory.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[800],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[800],
                    child: const Icon(Icons.error, color: Colors.red, size: 50),
                  ),
                ),
              ),
            ),
            actions: [
              if (isOwner)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  color: Colors.grey[900],
                  onSelected: (value) {
                    if (value == 'edit') {
                      setState(() => _isEditing = true);
                    } else if (value == 'delete') {
                      _deleteMemory();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Edit', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Caption
                  if (_isEditing)
                    TextField(
                      controller: _captionController,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                      maxLines: null,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[900],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    )
                  else
                    Text(
                      _memory.caption,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Tags
                  if (_memory.tags.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _memory.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0066FF).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '#$tag',
                            style: const TextStyle(
                              color: Color(0xFF0066FF),
                              fontSize: 14,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Visibility
                  if (_isEditing)
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Visibility', style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 10),
                          Row(
                            children: MemoryVisibility.values.map((visibility) {
                              final isSelected = _editVisibility == visibility;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _editVisibility = visibility),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      color: isSelected ? const Color(0xFF0066FF) : Colors.grey[800],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(visibility.icon, style: const TextStyle(fontSize: 20)),
                                        const SizedBox(height: 4),
                                        Text(
                                          visibility.displayName,
                                          style: const TextStyle(color: Colors.white, fontSize: 10),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    )
                  else
                    _buildInfoRow(
                      'Visibility',
                      '${_memory.visibility.icon} ${_memory.visibility.displayName}',
                    ),

                  const SizedBox(height: 15),

                  // Location
                  _buildInfoRow(
                    'Location',
                    '${_memory.latitude.toStringAsFixed(4)}, ${_memory.longitude.toStringAsFixed(4)}',
                    icon: Icons.location_on,
                  ),
                  const SizedBox(height: 15),

                  // Date
                  _buildInfoRow(
                    'Date',
                    DateFormat('MMMM d, y • h:mm a').format(_memory.createdAt),
                    icon: Icons.calendar_today,
                  ),
                  const SizedBox(height: 15),

                  // Stats
                  Row(
                    children: [
                      _buildStatBox('Views', _memory.viewCount.toString(), Icons.visibility),
                      const SizedBox(width: 15),
                      _buildStatBox('Likes', _memory.likeCount.toString(), Icons.favorite),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Action buttons
                  if (_isEditing)
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isEditing = false;
                                _captionController.text = _memory.caption;
                                _editVisibility = _memory.visibility;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[700],
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _updateMemory,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0066FF),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Save', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: _toggleLike,
                      icon: Icon(_isLiked ? Icons.favorite : Icons.favorite_border),
                      label: Text(_isLiked ? 'Unlike' : 'Like'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isLiked ? const Color(0xFFFF6B35) : const Color(0xFF0066FF),
                        minimumSize: const Size(double.infinity, 50),
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

  Widget _buildInfoRow(String label, String value, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: const Color(0xFF0066FF), size: 20),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(color: Colors.white, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF0066FF)),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

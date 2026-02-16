import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/memory.dart';
import '../services/memory_service.dart';
import 'memory_detail_screen.dart';

class MemoryMapScreen extends StatefulWidget {
  final String userId;
  final String currentUserId;

  const MemoryMapScreen({
    Key? key,
    required this.userId,
    required this.currentUserId,
  }) : super(key: key);

  @override
  _MemoryMapScreenState createState() => _MemoryMapScreenState();
}

class _MemoryMapScreenState extends State<MemoryMapScreen> {
  final _memoryService = MemoryService();
  GoogleMapController? _mapController;
  List<MemoryModel> _memories = [];
  Set<Marker> _markers = {};
  bool _isLoading = true;
  MemoryModel? _selectedMemory;

  // Default location (Bangalore, India)
  static const LatLng _defaultLocation = LatLng(12.9716, 77.5946);

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

      setState(() {
        _memories = memories;
        _createMarkers();
        _isLoading = false;
      });

      // Move camera to show all markers
      if (_memories.isNotEmpty && _mapController != null) {
        _fitMarkersInView();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load memories: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  void _createMarkers() {
    _markers = _memories.map((memory) {
      return Marker(
        markerId: MarkerId(memory.memoryId),
        position: LatLng(memory.latitude, memory.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          _getMarkerColor(memory.visibility),
        ),
        onTap: () => _onMarkerTapped(memory),
        infoWindow: InfoWindow(
          title: memory.caption,
          snippet: '${memory.visibility.icon} ${memory.visibility.displayName}',
        ),
      );
    }).toSet();
  }

  double _getMarkerColor(MemoryVisibility visibility) {
    switch (visibility) {
      case MemoryVisibility.public:
        return BitmapDescriptor.hueGreen;
      case MemoryVisibility.friends:
        return BitmapDescriptor.hueBlue;
      case MemoryVisibility.private:
        return BitmapDescriptor.hueGrey;
    }
  }

  void _onMarkerTapped(MemoryModel memory) {
    setState(() => _selectedMemory = memory);
  }

  void _fitMarkersInView() {
    if (_memories.isEmpty || _mapController == null) return;

    double minLat = _memories.first.latitude;
    double maxLat = _memories.first.latitude;
    double minLng = _memories.first.longitude;
    double maxLng = _memories.first.longitude;

    for (var memory in _memories) {
      if (memory.latitude < minLat) minLat = memory.latitude;
      if (memory.latitude > maxLat) maxLat = memory.latitude;
      if (memory.longitude < minLng) minLng = memory.longitude;
      if (memory.longitude > maxLng) maxLng = memory.longitude;
    }

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        100, // padding
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: const Text('Memory Map', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Map
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _defaultLocation,
              zoom: 12,
            ),
            markers: _markers,
            onMapCreated: (controller) {
              _mapController = controller;
              if (_memories.isNotEmpty) {
                _fitMarkersInView();
              }
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            mapToolbarEnabled: false,
          ),

          // Loading indicator
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),

          // Memory preview card
          if (_selectedMemory != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: _buildMemoryPreview(_selectedMemory!),
            ),

          // Legend
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Legend',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildLegendItem('🌍 Public', Colors.green),
                  _buildLegendItem('👥 Friends', Colors.blue),
                  _buildLegendItem('🔒 Private', Colors.grey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoryPreview(MemoryModel memory) {
    return GestureDetector(
      onTap: () => _navigateToDetail(memory),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                memory.thumbnailUrl ?? memory.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[800],
                    child: const Icon(Icons.error, color: Colors.red),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    memory.caption,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${memory.visibility.icon} ${memory.visibility.displayName}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),

            // Close button
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => setState(() => _selectedMemory = null),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}

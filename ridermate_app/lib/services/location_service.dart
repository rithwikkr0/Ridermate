import 'dart:async';
import 'dart:convert';
import 'dart:math';
import '../models/live_location.dart';

/// Service for tracking and sharing live locations
class LocationService {
  static const String _baseUrl = 'https://api.ridermate.com';
  
  // Mock data
  final Map<String, LiveLocation> _friendLocations = {};
  LocationSharingSettings _settings = LocationSharingSettings();
  LiveLocation? _myLocation;
  
  // Stream controllers
  final _locationsController = StreamController<Map<String, LiveLocation>>.broadcast();
  final _settingsController = StreamController<LocationSharingSettings>.broadcast();
  final _myLocationController = StreamController<LiveLocation?>.broadcast();
  
  Stream<Map<String, LiveLocation>> get locationsStream => _locationsController.stream;
  Stream<LocationSharingSettings> get settingsStream => _settingsController.stream;
  Stream<LiveLocation?> get myLocationStream => _myLocationController.stream;
  
  Timer? _locationTimer;
  Timer? _cleanupTimer;
  
  /// Start sharing location
  Future<void> startSharingLocation({
    required String userId,
    required String userName,
  }) async {
    try {
      // Enable location sharing
      _settings = _settings.copyWith(enabled: true);
      _settingsController.add(_settings);
      
      // Start periodic location updates (every 2-3 seconds)
      _locationTimer?.cancel();
      _locationTimer = Timer.periodic(Duration(seconds: 2), (_) async {
        await _updateMyLocation(userId, userName);
      });
      
      // Start cleanup timer to remove stale locations
      _startCleanupTimer();
    } catch (e) {
      throw Exception('Failed to start location sharing: $e');
    }
  }
  
  /// Stop sharing location
  Future<void> stopSharingLocation() async {
    try {
      _locationTimer?.cancel();
      _locationTimer = null;
      
      _settings = _settings.copyWith(enabled: false);
      _settingsController.add(_settings);
      
      _myLocation = null;
      _myLocationController.add(null);
      
      // TODO: Notify server to stop broadcasting location
      // await http.post(
      //   Uri.parse('$_baseUrl/api/location/stop-sharing'),
      // );
    } catch (e) {
      throw Exception('Failed to stop location sharing: $e');
    }
  }
  
  /// Update current location
  Future<void> _updateMyLocation(String userId, String userName) async {
    try {
      // TODO: Get actual GPS location using geolocator package
      // final position = await Geolocator.getCurrentPosition(
      //   desiredAccuracy: LocationAccuracy.high,
      // );
      
      // Mock location update - simulating movement
      final now = DateTime.now();
      final baseLatitude = 12.9716;
      final baseLongitude = 77.5946;
      
      // Simulate slight movement
      final offset = (now.millisecondsSinceEpoch % 1000) / 10000.0;
      
      _myLocation = LiveLocation(
        userId: userId,
        userName: userName,
        latitude: baseLatitude + offset,
        longitude: baseLongitude + offset,
        speed: 25.0 + (now.millisecondsSinceEpoch % 10),
        heading: (now.millisecondsSinceEpoch % 360).toDouble(),
        accuracy: 5.0,
        timestamp: now,
        isSharing: true,
      );
      
      _myLocationController.add(_myLocation);
      
      // Send location update to server
      await _sendLocationUpdate(_myLocation!);
    } catch (e) {
      print('Failed to update location: $e');
    }
  }
  
  /// Send location update to server
  Future<void> _sendLocationUpdate(LiveLocation location) async {
    try {
      // TODO: Replace with actual API call or WebSocket event
      // await http.post(
      //   Uri.parse('$_baseUrl/api/location/share'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: json.encode(location.toJson()),
      // );
      
      // Or via WebSocket:
      // webSocketService.sendLocationUpdate(location);
      
      await Future.delayed(Duration(milliseconds: 50));
    } catch (e) {
      print('Failed to send location update: $e');
    }
  }
  
  /// Get friend locations
  Future<Map<String, LiveLocation>> getFriendLocations() async {
    try {
      // TODO: Replace with actual API call
      // final response = await http.get(
      //   Uri.parse('$_baseUrl/api/location/friends'),
      // );
      //
      // if (response.statusCode == 200) {
      //   final List<dynamic> data = json.decode(response.body);
      //   final locations = <String, LiveLocation>{};
      //   for (var item in data) {
      //     final location = LiveLocation.fromJson(item);
      //     locations[location.userId] = location;
      //   }
      //   return locations;
      // }
      
      // Mock implementation
      await Future.delayed(Duration(milliseconds: 200));
      return Map.from(_friendLocations);
    } catch (e) {
      throw Exception('Failed to get friend locations: $e');
    }
  }
  
  /// Update friend location (called by WebSocket)
  void updateFriendLocation(LiveLocation location) {
    // Check if we have permission to see this friend's location
    if (!_canViewLocation(location.userId)) {
      return;
    }
    
    _friendLocations[location.userId] = location;
    _locationsController.add(Map.from(_friendLocations));
  }
  
  /// Remove friend location (when they stop sharing)
  void removeFriendLocation(String userId) {
    _friendLocations.remove(userId);
    _locationsController.add(Map.from(_friendLocations));
  }
  
  /// Update location sharing settings
  Future<void> updateSettings(LocationSharingSettings settings) async {
    try {
      // TODO: Save settings to server
      // await http.post(
      //   Uri.parse('$_baseUrl/api/location/settings'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: json.encode(settings.toJson()),
      // );
      
      _settings = settings;
      _settingsController.add(_settings);
      
      // If disabled, stop sharing
      if (!settings.enabled && _locationTimer != null) {
        await stopSharingLocation();
      }
    } catch (e) {
      throw Exception('Failed to update settings: $e');
    }
  }
  
  /// Get current location sharing settings
  LocationSharingSettings getSettings() {
    return _settings;
  }
  
  /// Check if we can view a friend's location based on privacy settings
  bool _canViewLocation(String friendId) {
    switch (_settings.privacy) {
      case LocationPrivacy.none:
        return false;
      case LocationPrivacy.friendsOnly:
        return true; // Assume all friends can see
      case LocationPrivacy.selectedFriends:
        return _settings.allowedFriends.contains(friendId);
      case LocationPrivacy.public:
        return true;
    }
  }
  
  /// Start cleanup timer to remove stale locations
  void _startCleanupTimer() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(Duration(seconds: 10), (_) {
      _cleanupStaleLocations();
    });
  }
  
  /// Remove locations that haven't been updated in 30+ seconds
  void _cleanupStaleLocations() {
    final staleUserIds = <String>[];
    
    _friendLocations.forEach((userId, location) {
      if (location.isStale) {
        staleUserIds.add(userId);
      }
    });
    
    for (var userId in staleUserIds) {
      _friendLocations.remove(userId);
    }
    
    if (staleUserIds.isNotEmpty) {
      _locationsController.add(Map.from(_friendLocations));
    }
  }
  
  // Constant for degree to radian conversion
  static const _degreesToRadiansMultiplier = pi / 180;
  
  /// Calculate distance between two locations in kilometers
  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // km
    
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);
    
    final sinHalfDLat = sin(dLat / 2);
    final sinHalfDLon = sin(dLon / 2);
    final cosLat1 = cos(_degreesToRadians(lat1));
    final cosLat2 = cos(_degreesToRadians(lat2));
    
    final a = sinHalfDLat * sinHalfDLat +
        cosLat1 * cosLat2 * sinHalfDLon * sinHalfDLon;
    
    final c = 2 * asin(sqrt(a));
    
    return earthRadius * c;
  }
  
  double _degreesToRadians(double degrees) {
    return degrees * _degreesToRadiansMultiplier;
  }
  
  /// Get my current location
  LiveLocation? getMyLocation() {
    return _myLocation;
  }
  
  /// Dispose streams and timers
  void dispose() {
    _locationTimer?.cancel();
    _cleanupTimer?.cancel();
    _locationsController.close();
    _settingsController.close();
    _myLocationController.close();
  }
}

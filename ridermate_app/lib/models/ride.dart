class Ride {
  final String rideId;
  final String userId;
  final DateTime startTime;
  final DateTime endTime;
  final double distance; // km
  final int duration; // seconds
  final double avgSpeed; // km/h
  final double maxSpeed; // km/h
  final int overspeeds;
  final List<GpsCoordinate> routeCoordinates;
  final double safetyScore; // 0-100
  final String aiSummary;
  final WeatherData? weatherData;
  final String terrain; // urban, highway, mixed
  final String timeOfDay; // morning, afternoon, evening, night
  final String dayOfWeek;
  final int memoryCount;
  final List<String> friendsOnRide;
  final DateTime createdAt;

  Ride({
    required this.rideId,
    required this.userId,
    required this.startTime,
    required this.endTime,
    required this.distance,
    required this.duration,
    required this.avgSpeed,
    required this.maxSpeed,
    required this.overspeeds,
    required this.routeCoordinates,
    required this.safetyScore,
    required this.aiSummary,
    this.weatherData,
    required this.terrain,
    required this.timeOfDay,
    required this.dayOfWeek,
    required this.memoryCount,
    required this.friendsOnRide,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'rideId': rideId,
      'userId': userId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'distance': distance,
      'duration': duration,
      'avgSpeed': avgSpeed,
      'maxSpeed': maxSpeed,
      'overspeeds': overspeeds,
      'routeCoordinates': routeCoordinates.map((c) => c.toJson()).toList(),
      'safetyScore': safetyScore,
      'aiSummary': aiSummary,
      'weatherData': weatherData?.toJson(),
      'terrain': terrain,
      'timeOfDay': timeOfDay,
      'dayOfWeek': dayOfWeek,
      'memoryCount': memoryCount,
      'friendsOnRide': friendsOnRide,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Ride.fromJson(Map<String, dynamic> json) {
    return Ride(
      rideId: json['rideId'],
      userId: json['userId'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      distance: json['distance'].toDouble(),
      duration: json['duration'],
      avgSpeed: json['avgSpeed'].toDouble(),
      maxSpeed: json['maxSpeed'].toDouble(),
      overspeeds: json['overspeeds'],
      routeCoordinates: (json['routeCoordinates'] as List)
          .map((c) => GpsCoordinate.fromJson(c))
          .toList(),
      safetyScore: json['safetyScore'].toDouble(),
      aiSummary: json['aiSummary'],
      weatherData: json['weatherData'] != null
          ? WeatherData.fromJson(json['weatherData'])
          : null,
      terrain: json['terrain'],
      timeOfDay: json['timeOfDay'],
      dayOfWeek: json['dayOfWeek'],
      memoryCount: json['memoryCount'],
      friendsOnRide: List<String>.from(json['friendsOnRide']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  String get formattedDuration {
    final hours = duration ~/ 3600;
    final minutes = (duration % 3600) ~/ 60;
    final seconds = duration % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  String get formattedDistance {
    if (distance >= 1) {
      return '${distance.toStringAsFixed(2)} km';
    } else {
      return '${(distance * 1000).toStringAsFixed(0)} m';
    }
  }
}

class GpsCoordinate {
  final double latitude;
  final double longitude;
  final double? altitude;
  final DateTime timestamp;

  GpsCoordinate({
    required this.latitude,
    required this.longitude,
    this.altitude,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory GpsCoordinate.fromJson(Map<String, dynamic> json) {
    return GpsCoordinate(
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      altitude: json['altitude']?.toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class WeatherData {
  final double temperature;
  final String conditions;
  final double? humidity;
  final double? windSpeed;

  WeatherData({
    required this.temperature,
    required this.conditions,
    this.humidity,
    this.windSpeed,
  });

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'conditions': conditions,
      'humidity': humidity,
      'windSpeed': windSpeed,
    };
  }

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temperature: json['temperature'].toDouble(),
      conditions: json['conditions'],
      humidity: json['humidity']?.toDouble(),
      windSpeed: json['windSpeed']?.toDouble(),
    );
  }
}

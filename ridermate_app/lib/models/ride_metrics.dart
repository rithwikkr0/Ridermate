class RideMetrics {
  final double distance; // in kilometers
  final int duration; // in seconds
  final double avgSpeed; // in km/h
  final int overspeeds; // count of overspeed events
  final double maxSpeed; // in km/h
  final List<double> speedPattern; // speed readings for analysis
  final DateTime timestamp;

  RideMetrics({
    required this.distance,
    required this.duration,
    required this.avgSpeed,
    required this.overspeeds,
    required this.maxSpeed,
    required this.speedPattern,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'distance': distance,
        'duration': duration,
        'avgSpeed': avgSpeed,
        'overspeeds': overspeeds,
        'maxSpeed': maxSpeed,
        'speedPattern': speedPattern,
        'timestamp': timestamp.toIso8601String(),
      };

  factory RideMetrics.fromJson(Map<String, dynamic> json) => RideMetrics(
        distance: json['distance']?.toDouble() ?? 0.0,
        duration: json['duration'] ?? 0,
        avgSpeed: json['avgSpeed']?.toDouble() ?? 0.0,
        overspeeds: json['overspeeds'] ?? 0,
        maxSpeed: json['maxSpeed']?.toDouble() ?? 0.0,
        speedPattern: (json['speedPattern'] as List?)?.map((e) => e.toDouble()).toList() ?? [],
        timestamp: DateTime.parse(json['timestamp']),
      );
}

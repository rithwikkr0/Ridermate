import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import '../models/ride.dart';

class DataExportService {
  Future<File> exportToCSV(List<Ride> rides, String userId) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'rides_export_${userId}_${DateTime.now().millisecondsSinceEpoch}.csv';
    final file = File('${directory.path}/$fileName');

    final List<List<dynamic>> rows = [
      [
        'Ride ID',
        'Start Time',
        'End Time',
        'Distance (km)',
        'Duration (s)',
        'Avg Speed (km/h)',
        'Max Speed (km/h)',
        'Overspeeds',
        'Safety Score',
        'Terrain',
        'Time of Day',
        'Day of Week',
        'AI Summary',
      ],
    ];

    for (var ride in rides) {
      rows.add([
        ride.rideId,
        ride.startTime.toIso8601String(),
        ride.endTime.toIso8601String(),
        ride.distance.toStringAsFixed(2),
        ride.duration,
        ride.avgSpeed.toStringAsFixed(2),
        ride.maxSpeed.toStringAsFixed(2),
        ride.overspeeds,
        ride.safetyScore.toStringAsFixed(2),
        ride.terrain,
        ride.timeOfDay,
        ride.dayOfWeek,
        ride.aiSummary,
      ]);
    }

    final csvData = const ListToCsvConverter().convert(rows);
    await file.writeAsString(csvData);

    return file;
  }

  Future<File> exportToJSON(List<Ride> rides, String userId) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'rides_export_${userId}_${DateTime.now().millisecondsSinceEpoch}.json';
    final file = File('${directory.path}/$fileName');

    final jsonData = json.encode({
      'exportDate': DateTime.now().toIso8601String(),
      'userId': userId,
      'totalRides': rides.length,
      'rides': rides.map((r) => r.toJson()).toList(),
    });

    await file.writeAsString(jsonData);

    return file;
  }

  Future<String> generateShareableText(List<Ride> rides) async {
    if (rides.isEmpty) {
      return 'No rides to share';
    }

    final totalDistance = rides.fold<double>(0, (sum, r) => sum + r.distance);
    final totalTime = rides.fold<int>(0, (sum, r) => sum + r.duration);
    final avgSafety = rides.fold<double>(0, (sum, r) => sum + r.safetyScore) / rides.length;

    final hours = totalTime ~/ 3600;
    final minutes = (totalTime % 3600) ~/ 60;

    return '''
🚴 RiderMate Stats 🚴

Total Rides: ${rides.length}
Total Distance: ${totalDistance.toStringAsFixed(1)} km
Total Time: ${hours}h ${minutes}m
Avg Safety Score: ${avgSafety.toStringAsFixed(1)}/100

Keep riding safe! 🛡️
    ''';
  }
}

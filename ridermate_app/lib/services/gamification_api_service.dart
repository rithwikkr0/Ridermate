import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/leaderboard_entry.dart';
import '../models/badge.dart';
import '../models/achievement.dart';
import '../models/points.dart';
import '../models/streak.dart';
import 'api_config.dart';

class GamificationApiService {
  // Get base URL from config
  static String get baseUrl => ApiConfig.baseUrl;

  // Leaderboard endpoints
  static Future<List<LeaderboardEntry>> getGlobalLeaderboard({
    String period = 'all_time',
    int limit = 100,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/leaderboard/global?period=$period&limit=$limit'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['leaderboard'] as List)
            .map((item) => LeaderboardEntry.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching global leaderboard: $e');
      return [];
    }
  }

  static Future<List<LeaderboardEntry>> getFriendsLeaderboard(
    String userId, {
    String period = 'all_time',
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/leaderboard/friends/$userId?period=$period'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['leaderboard'] as List)
            .map((item) => LeaderboardEntry.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching friends leaderboard: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> getUserRank(
    String userId, {
    String period = 'all_time',
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId/rank?period=$period'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {};
    } catch (e) {
      print('Error fetching user rank: $e');
      return {};
    }
  }

  // Points endpoints
  static Future<UserPoints?> getUserPoints(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/points/$userId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return UserPoints.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error fetching user points: $e');
      return null;
    }
  }

  static Future<List<PointsTransaction>> getPointsHistory(
    String userId, {
    int limit = 50,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/points/$userId/history?limit=$limit'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['history'] as List)
            .map((item) => PointsTransaction.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching points history: $e');
      return [];
    }
  }

  // Badges endpoints
  static Future<List<Badge>> getAllBadges() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/badges/all'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['badges'] as List)
            .map((item) => Badge.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching all badges: $e');
      return [];
    }
  }

  static Future<List<Badge>> getUserBadges(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/badges/$userId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['badges'] as List)
            .map((item) => Badge.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching user badges: $e');
      return [];
    }
  }

  // Achievements endpoints
  static Future<List<Achievement>> getAllAchievements() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/achievements/all'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['achievements'] as List)
            .map((item) => Achievement.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching all achievements: $e');
      return [];
    }
  }

  static Future<List<Achievement>> getUserAchievements(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/achievements/$userId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['achievements'] as List)
            .map((item) => Achievement.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching user achievements: $e');
      return [];
    }
  }
}

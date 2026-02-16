import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart';
import '../models/ride_metrics.dart';
import 'openai_service.dart';
import 'ai_analysis_service.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final OpenAIService _openAIService = OpenAIService();
  final AIAnalysisService _analysisService = AIAnalysisService();
  
  final List<ChatMessage> _messages = [];
  static const String _storageKey = 'chat_messages';
  static const int _maxMessages = 50;
  
  // Configuration constants
  static const Duration _contextWindowDuration = Duration(hours: 1);
  static const int _maxContextMessages = 10;

  List<ChatMessage> get messages => List.unmodifiable(_messages);

  Future<void> loadMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = prefs.getString(_storageKey);
      
      if (messagesJson != null) {
        final List<dynamic> decoded = jsonDecode(messagesJson);
        _messages.clear();
        _messages.addAll(
          decoded.map((json) => ChatMessage.fromJson(json)).toList(),
        );
      }
    } catch (e) {
      // If loading fails, start with empty messages
      _messages.clear();
    }
  }

  Future<void> saveMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = jsonEncode(
        _messages.map((m) => m.toJson()).toList(),
      );
      await prefs.setString(_storageKey, messagesJson);
    } catch (e) {
      // Silently fail on save error
    }
  }

  void addMessage(ChatMessage message) {
    _messages.add(message);
    
    // Keep only the most recent messages
    if (_messages.length > _maxMessages) {
      _messages.removeRange(0, _messages.length - _maxMessages);
    }
    
    saveMessages();
  }

  Future<ChatMessage> sendMessage(String content, {RideMetrics? currentRide, List<RideMetrics>? rideHistory}) async {
    // Add user message
    final userMessage = ChatMessage(
      role: 'user',
      content: content,
      timestamp: DateTime.now(),
    );
    addMessage(userMessage);

    try {
      // Build context-aware system prompt
      final systemPrompt = _buildSystemPrompt(currentRide, rideHistory);
      
      // Build conversation history for context
      final conversationHistory = _messages
          .where((m) => m.timestamp.isAfter(DateTime.now().subtract(_contextWindowDuration)))
          .take(_maxContextMessages)
          .map((m) => {
                'role': m.role,
                'content': m.content,
              })
          .toList();

      // Get AI response
      final responseContent = await _openAIService.chat(
        systemPrompt: systemPrompt,
        userMessage: content,
        conversationHistory: conversationHistory,
      );

      // Create assistant message
      final assistantMessage = ChatMessage(
        role: 'assistant',
        content: responseContent,
        timestamp: DateTime.now(),
      );
      addMessage(assistantMessage);

      return assistantMessage;
    } catch (e) {
      // Create error message
      final errorMessage = ChatMessage(
        role: 'assistant',
        content: 'I apologize, I\'m having trouble right now. Please try again in a moment.',
        timestamp: DateTime.now(),
      );
      addMessage(errorMessage);
      return errorMessage;
    }
  }

  String _buildSystemPrompt(RideMetrics? currentRide, List<RideMetrics>? rideHistory) {
    String prompt = '''You are RiderMate AI, a friendly and knowledgeable cycling companion. 
You help riders improve their performance, stay safe, and enjoy cycling.

Key traits:
- Encouraging and supportive
- Safety-focused
- Data-informed but conversational
- Concise and actionable advice
''';

    if (currentRide != null) {
      final safetyScore = _analysisService.calculateSafetyScore(currentRide);
      prompt += '''

Current ride context:
- Distance: ${currentRide.distance.toStringAsFixed(2)} km
- Duration: ${(currentRide.duration / 60).toStringAsFixed(0)} minutes
- Average Speed: ${currentRide.avgSpeed.toStringAsFixed(1)} km/h
- Safety Score: ${safetyScore.toStringAsFixed(1)}/100
- Overspeed Events: ${currentRide.overspeeds}
''';
    }

    if (rideHistory != null && rideHistory.isNotEmpty) {
      final totalDistance = rideHistory.map((r) => r.distance).reduce((a, b) => a + b);
      final avgSafety = rideHistory.map((r) => _analysisService.calculateSafetyScore(r)).reduce((a, b) => a + b) / rideHistory.length;
      
      prompt += '''

Rider history:
- Total rides: ${rideHistory.length}
- Total distance: ${totalDistance.toStringAsFixed(1)} km
- Average safety: ${avgSafety.toStringAsFixed(1)}/100
''';
    }

    return prompt;
  }

  void clearMessages() {
    _messages.clear();
    saveMessages();
  }
}

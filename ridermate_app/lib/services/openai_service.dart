import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OpenAIService {
  static final OpenAIService _instance = OpenAIService._internal();
  factory OpenAIService() => _instance;
  OpenAIService._internal();

  final String _baseUrl = 'https://api.openai.com/v1';
  final Duration _timeout = Duration(seconds: 30);
  
  // Configuration constants
  static const String _testKeyPlaceholder = 'sk-test-key-placeholder';
  static const bool _enableDemoMode = true;

  String get _apiKey => dotenv.env['OPENAI_API_KEY'] ?? '';
  String get _model => dotenv.env['OPENAI_MODEL'] ?? 'gpt-3.5-turbo';
  
  bool get _isDemoMode => _enableDemoMode && (_apiKey.isEmpty || _apiKey == _testKeyPlaceholder);

  Future<String> chat({
    required String systemPrompt,
    required String userMessage,
    List<Map<String, String>>? conversationHistory,
  }) async {
    try {
      if (_isDemoMode) {
        // Return a mock response for demo purposes
        return _getMockResponse(userMessage);
      }

      final messages = <Map<String, String>>[];
      
      // Add system prompt
      messages.add({
        'role': 'system',
        'content': systemPrompt,
      });

      // Add conversation history if provided
      if (conversationHistory != null) {
        messages.addAll(conversationHistory);
      }

      // Add current user message
      messages.add({
        'role': 'user',
        'content': userMessage,
      });

      final response = await http
          .post(
            Uri.parse('$_baseUrl/chat/completions'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
            },
            body: jsonEncode({
              'model': _model,
              'messages': messages,
              'temperature': 0.7,
              'max_tokens': 500,
            }),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('OpenAI API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Request timeout - please try again');
      }
      // Return fallback response on error
      return _getFallbackResponse(userMessage);
    }
  }

  String _getMockResponse(String message) {
    final lowerMessage = message.toLowerCase();
    
    if (lowerMessage.contains('how was my ride') || lowerMessage.contains('ride analysis')) {
      return 'Great ride! You maintained a steady pace and showed good speed consistency. Your safety score is strong. Keep up the excellent work!';
    } else if (lowerMessage.contains('improve') || lowerMessage.contains('tips')) {
      return 'Here are some tips to improve:\n\n1. Maintain consistent speed to improve safety\n2. Reduce overspeed events\n3. Plan routes with better road conditions\n4. Take regular breaks on long rides';
    } else if (lowerMessage.contains('safety') || lowerMessage.contains('safe')) {
      return 'Safety is paramount! Always:\n- Wear a helmet\n- Follow traffic rules\n- Stay visible with lights\n- Maintain your bike regularly\n- Avoid distractions while riding';
    } else if (lowerMessage.contains('city') || lowerMessage.contains('traffic')) {
      return 'City riding tips:\n- Stay alert at intersections\n- Use bike lanes when available\n- Signal your intentions\n- Maintain safe distance from vehicles\n- Be predictable in your movements';
    } else {
      return 'I\'m here to help with your cycling journey! Ask me about ride analysis, safety tips, or how to improve your performance.';
    }
  }

  String _getFallbackResponse(String message) {
    return 'I\'m having trouble connecting right now, but I\'m here to help! Please try again in a moment.';
  }
}

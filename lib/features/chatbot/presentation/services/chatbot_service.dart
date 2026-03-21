import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/app_language_service.dart';

class ChatbotTurn {
  final String role;
  final String content;

  const ChatbotTurn({required this.role, required this.content});
}

class ChatbotException implements Exception {
  final String message;

  const ChatbotException(this.message);

  @override
  String toString() => 'ChatbotException: $message';
}

class ChatbotService {
  final http.Client _client;

  ChatbotService({http.Client? client}) : _client = client ?? http.Client();

  bool get isConfigured => AppConstants.groqApiKey.trim().isNotEmpty;

  Future<String> generateReply(
    List<ChatbotTurn> conversation, {
    AppLanguage? language,
  }) async {
    final t = AppLanguageService.instance;
    final selectedLanguage = language ?? t.language;
    final apiKey = AppConstants.groqApiKey.trim();
    if (apiKey.isEmpty) {
      throw ChatbotException(t.tr('chatbot.errors.missing_key'));
    }

    final payload = {
      'model': AppConstants.groqChatModel,
      'temperature': 0.4,
      'top_p': 1,
      'stream': false,
      'max_completion_tokens': 300,
      'messages': [
        {
          'role': 'system',
          'content': _buildSystemPrompt(selectedLanguage.chatbotName),
        },
        ...conversation
            .where((turn) => turn.content.trim().isNotEmpty)
            .take(12)
            .map((turn) => {'role': turn.role, 'content': turn.content.trim()}),
      ],
    };

    http.Response response;
    try {
      response = await _client
          .post(
            Uri.parse('${AppConstants.groqApiBaseUrl}/chat/completions'),
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      throw ChatbotException(t.tr('chatbot.errors.connect'));
    }

    final responseMap = _decodeMap(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ChatbotException(
        _extractError(responseMap) ??
            t.tr(
              'chatbot.errors.api',
              params: {'status': response.statusCode.toString()},
            ),
      );
    }

    final choices = responseMap['choices'];
    if (choices is! List || choices.isEmpty) {
      throw ChatbotException(t.tr('chatbot.errors.unusable'));
    }

    final firstChoice = choices.first;
    if (firstChoice is! Map) {
      throw ChatbotException(t.tr('chatbot.errors.unexpected_format'));
    }

    final message = firstChoice['message'];
    if (message is! Map) {
      throw ChatbotException(t.tr('chatbot.errors.expected_message'));
    }

    final content = message['content'];
    final parsedContent = _normalizeContent(content);
    if (parsedContent.isEmpty) {
      throw ChatbotException(t.tr('chatbot.errors.empty'));
    }

    return parsedContent;
  }

  String _buildSystemPrompt(String targetLanguage) {
    return '''
You are a support assistant for a personal safety app in Bolivia.
Always answer in $targetLanguage with clear, empathetic and practical wording.
Prioritize short and actionable guidance about safety, emotional support, reports and help routes.
If the user describes immediate danger, suggest using the app SOS alert, moving to a safer place, and contacting emergency services or a trusted person.
Do not invent addresses, phone numbers, institutions or unconfirmed facts.
Do not say that you are a therapist, lawyer or police officer.
Keep answers under 140 words unless the user asks for more detail.
''';
  }

  Map<String, dynamic> _decodeMap(String body) {
    if (body.trim().isEmpty) {
      return <String, dynamic>{};
    }

    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
    } catch (_) {
      return <String, dynamic>{};
    }

    return <String, dynamic>{};
  }

  String? _extractError(Map<String, dynamic> responseMap) {
    final error = responseMap['error'];
    if (error is Map<String, dynamic>) {
      final message = error['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    }

    final message = responseMap['message'];
    if (message is String && message.trim().isNotEmpty) {
      return message;
    }

    return null;
  }

  String _normalizeContent(dynamic content) {
    if (content is String) {
      return content.trim();
    }

    if (content is List) {
      final buffer = StringBuffer();
      for (final item in content) {
        if (item is Map && item['type'] == 'text') {
          final text = item['text'];
          if (text is String && text.trim().isNotEmpty) {
            if (buffer.isNotEmpty) {
              buffer.writeln();
            }
            buffer.write(text.trim());
          }
        }
      }
      return buffer.toString().trim();
    }

    return '';
  }
}

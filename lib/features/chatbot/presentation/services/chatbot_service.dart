import 'dart:convert';

import 'package:http/http.dart' as http;

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
  static const String _ragApiBaseUrl = String.fromEnvironment(
    'RAG_API_BASE_URL',
    defaultValue: 'http://144.22.43.169:8000',
  );

  final http.Client _client;
  final String _conversationId;

  ChatbotService({http.Client? client, String? conversationId})
    : _client = client ?? http.Client(),
      _conversationId =
          conversationId ?? 'chat_${DateTime.now().millisecondsSinceEpoch}';

  bool get isConfigured => _ragApiBaseUrl.trim().isNotEmpty;

  Future<String> generateReply(
    List<ChatbotTurn> conversation, {
    AppLanguage? language,
  }) async {
    final selectedLanguage = language ?? AppLanguageService.instance.language;
    final question = _extractLatestQuestion(conversation);
    if (question.isEmpty) {
      throw ChatbotException(
        _t(
          es: 'Escribe un mensaje para consultar el chatbot.',
          en: 'Write a message before asking the chatbot.',
          ay: 'Chatbot jisktanatakixa maya mensaje qillqt\'am.',
          qu: 'Chatbotta tapunaykipaq huk mensajeta qillqay.',
        ),
      );
    }

    http.Response response;
    try {
      response = await _client
          .get(
            _buildUri(
              '/rag/query',
              queryParameters: {
                'question': _buildQuestion(selectedLanguage, question),
                'conversation_id': _conversationId,
              },
            ),
            headers: const {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      throw ChatbotException(
        _t(
          es: 'No se pudo conectar con el chatbot de apoyo.',
          en: 'Could not connect to the support chatbot.',
          ay: 'Janiw yanapa chatbot ukar mantanjamakiti.',
          qu: 'Yanapay chatbotman mana conectayta atikurqanchu.',
        ),
      );
    }

    final responseMap = _decodeMap(response.bodyBytes);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ChatbotException(
        _extractError(responseMap) ??
            _t(
              es:
                  'El chatbot devolvio un error ${response.statusCode}. Intenta nuevamente.',
              en:
                  'The chatbot returned error ${response.statusCode}. Please try again.',
              ay:
                  'Chatbot ukax pantjawi ${response.statusCode} kutt\'ayawayi. Wasitat yant\'am.',
              qu:
                  'Chatbotqa pantay ${response.statusCode} kutichirqa. Wataqmanta yant\'ay.',
            ),
      );
    }

    if (responseMap['success'] == false) {
      throw ChatbotException(
        _extractError(responseMap) ??
            _t(
              es: 'El chatbot no pudo procesar tu consulta.',
              en: 'The chatbot could not process your request.',
              ay: 'Chatbot ukax janiw jiskt\'am lurkiti.',
              qu: 'Chatbotqa tapuyniykita mana procesayta atikurqanchu.',
            ),
      );
    }

    final data = _extractData(responseMap);
    final answer = _extractAnswer(data);
    if (answer.isEmpty) {
      throw ChatbotException(
        _t(
          es: 'El chatbot no devolvio una respuesta util.',
          en: 'The chatbot did not return a useful answer.',
          ay: 'Chatbot ukax janiw askicha respuesta churkiti.',
          qu: 'Chatbotqa mana allin kutichiyta quwarqanchu.',
        ),
      );
    }

    return answer;
  }

  Uri _buildUri(
    String path, {
    Map<String, String>? queryParameters,
  }) {
    final baseUri = Uri.parse(_ragApiBaseUrl);
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final basePath = baseUri.path.endsWith('/')
        ? baseUri.path.substring(0, baseUri.path.length - 1)
        : baseUri.path;
    final resolvedPath = '$basePath$normalizedPath';

    return baseUri.replace(
      path: resolvedPath.isEmpty ? '/' : resolvedPath,
      queryParameters: (queryParameters?.isEmpty ?? true)
          ? null
          : queryParameters,
    );
  }

  String _extractLatestQuestion(List<ChatbotTurn> conversation) {
    for (final turn in conversation.reversed) {
      if (turn.role == 'user' && turn.content.trim().isNotEmpty) {
        return turn.content.trim();
      }
    }

    return '';
  }

  String _buildQuestion(AppLanguage language, String question) {
    if (language.code == 'es') {
      return question;
    }

    return 'Responde en ${language.chatbotName}. Pregunta: $question';
  }

  Map<String, dynamic> _decodeMap(List<int> bodyBytes) {
    if (bodyBytes.isEmpty) {
      return <String, dynamic>{};
    }

    final body = utf8.decode(bodyBytes, allowMalformed: true);
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

  Map<String, dynamic> _extractData(Map<String, dynamic> responseMap) {
    final data = responseMap['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return data.map((key, value) => MapEntry(key.toString(), value));
    }
    return <String, dynamic>{};
  }

  String? _extractError(Map<String, dynamic> responseMap) {
    final detail = responseMap['detail'];
    if (detail is String && detail.trim().isNotEmpty) {
      return detail.trim();
    }
    if (detail is List) {
      for (final item in detail) {
        if (item is Map) {
          final message = item['msg'];
          if (message is String && message.trim().isNotEmpty) {
            return message.trim();
          }
        }
        if (item is String && item.trim().isNotEmpty) {
          return item.trim();
        }
      }
    }

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

  String _extractAnswer(Map<String, dynamic> data) {
    final answer = data['answer'];
    if (answer is String && answer.trim().isNotEmpty) {
      return answer.trim();
    }

    final message = data['message'];
    if (message is String && message.trim().isNotEmpty) {
      return message.trim();
    }

    return '';
  }

  String _t({
    required String es,
    required String en,
    required String ay,
    required String qu,
  }) {
    return AppLanguageService.instance.pick(es: es, en: en, ay: ay, qu: qu);
  }
}

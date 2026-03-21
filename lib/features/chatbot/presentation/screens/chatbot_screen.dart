import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/localization/app_language_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../services/chatbot_service.dart';
import '../widgets/chat_message_bubble.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatbotService _chatbotService = ChatbotService();
  late final List<_ChatMessage> _messages = [
    _ChatMessage(
      text: AppLanguageService.instance.tr('chatbot.intro'),
      isUser: false,
    ),
  ];

  bool _isBotTyping = false;

  List<String> _quickPrompts(BuildContext context) {
    return [
      context.tr('chatbot.quick.urgent'),
      context.tr('chatbot.quick.emotional'),
      context.tr('chatbot.quick.report'),
      context.tr('chatbot.quick.center'),
    ];
  }

  Future<void> _sendMessage([String? presetMessage]) async {
    final rawMessage = presetMessage ?? _messageController.text;
    final message = rawMessage.trim();
    if (message.isEmpty || _isBotTyping) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _messages.add(_ChatMessage(text: message, isUser: true));
      _messageController.clear();
      _isBotTyping = true;
    });

    _scrollToBottom();

    try {
      final reply = await _chatbotService.generateReply(
        _buildConversationTurns(),
        language: context.appLanguage,
      );
      if (!mounted) return;

      setState(() {
        _messages.add(_ChatMessage(text: reply, isUser: false));
        _isBotTyping = false;
      });
    } on ChatbotException catch (error) {
      if (!mounted) return;

      setState(() {
        _messages.add(_ChatMessage(text: error.message, isUser: false));
        _isBotTyping = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _messages.add(
          _ChatMessage(
            text: context.tr('chatbot.errors.unexpected'),
            isUser: false,
          ),
        );
        _isBotTyping = false;
      });
    }

    _scrollToBottom();
  }

  List<ChatbotTurn> _buildConversationTurns() {
    final relevantMessages = _messages.skip(1).toList();
    if (relevantMessages.length > 10) {
      return relevantMessages
          .sublist(relevantMessages.length - 10)
          .map(
            (message) => ChatbotTurn(
              role: message.isUser ? 'user' : 'assistant',
              content: message.text,
            ),
          )
          .toList();
    }

    return relevantMessages
        .map(
          (message) => ChatbotTurn(
            role: message.isUser ? 'user' : 'assistant',
            content: message.text,
          ),
        )
        .toList();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quickPrompts = _quickPrompts(context);
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(title: Text(context.tr('chatbot.title'))),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            SizedBox(
              height: 42,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: quickPrompts.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final prompt = quickPrompts[index];
                  return ActionChip(
                    onPressed: () => _sendMessage(prompt),
                    backgroundColor: AppTheme.cardBg,
                    side: const BorderSide(color: AppTheme.divider),
                    label: Text(
                      prompt,
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: AppTheme.divider.withValues(alpha: 0.70),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.secondary.withValues(alpha: 0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Stack(
                      children: [
                        const Positioned.fill(
                          child: IgnorePointer(child: _ChatStageBackground()),
                        ),
                        ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                          itemCount: _messages.length + (_isBotTyping ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _messages.length) {
                              return const ChatMessageBubble(
                                text: '',
                                isUser: false,
                                isTyping: true,
                              );
                            }

                            final message = _messages[index];
                            return ChatMessageBubble(
                              text: message.text,
                              isUser: message.isUser,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: const BoxDecoration(
                color: AppTheme.surface,
                border: Border(top: BorderSide(color: AppTheme.divider)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: context.tr('chatbot.hint'),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 54,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isBotTyping ? null : _sendMessage,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: const Icon(Icons.send_rounded, size: 22),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;

  const _ChatMessage({required this.text, required this.isUser});
}

class _ChatStageBackground extends StatelessWidget {
  const _ChatStageBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFCF8),
            Color(0xFFFFEDF2),
            Color(0xFFEAF7F8),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -24,
            right: -12,
            child: _GlowOrb(
              size: 150,
              color: AppTheme.primaryLight.withValues(alpha: 0.42),
            ),
          ),
          Positioned(
            bottom: 70,
            left: -30,
            child: _GlowOrb(
              size: 128,
              color: const Color(0x99B5DEE3),
            ),
          ),
          Positioned(
            top: 96,
            left: 36,
            child: _RingOrb(
              size: 54,
              color: AppTheme.secondary.withValues(alpha: 0.28),
            ),
          ),
          Positioned(
            top: 54,
            right: 48,
            child: _RingOrb(
              size: 28,
              color: AppTheme.primary.withValues(alpha: 0.22),
            ),
          ),
          Positioned(
            bottom: 140,
            right: 30,
            child: _RingOrb(
              size: 72,
              color: AppTheme.secondary.withValues(alpha: 0.22),
            ),
          ),
          Positioned(
            top: 26,
            left: 18,
            child: Transform.rotate(
              angle: -math.pi / 18,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.80),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppTheme.divider.withValues(alpha: 0.80),
                  ),
                ),
                child: Text(
                  context.tr('chatbot.support_pet_note'),
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _RingOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _RingOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1.3),
      ),
    );
  }
}

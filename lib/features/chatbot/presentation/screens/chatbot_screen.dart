import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../services/chatbot_service.dart';
import '../widgets/chat_message_bubble.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  static const String _assistantAvatarUrl =
      'https://images.unsplash.com/photo-1518791841217-8f162f1e1131?auto=format&fit=crop&w=200&q=80';

  static const List<String> _quickPrompts = [
    'Necesito ayuda urgente',
    'Quiero apoyo emocional',
    'Como hago una denuncia',
    'Busco un centro de apoyo',
  ];

  static const List<_ChatBackgroundOption> _backgroundOptions = [
    _ChatBackgroundOption(
      name: 'Brisa',
      icon: Icons.air_rounded,
      gradientColors: <Color>[
        Color(0xFFFFFCF8),
        Color(0xFFFFE4E4),
        Color(0xFFF8E8F9),
      ],
      orbColors: <Color>[Color(0x99FEC1B6), Color(0x99F3A6BA)],
      ringColor: Color(0x55DF678F),
    ),
    _ChatBackgroundOption(
      name: 'Jardin',
      icon: Icons.local_florist_rounded,
      gradientColors: <Color>[
        Color(0xFFFFFBF2),
        Color(0xFFE7F6ED),
        Color(0xFFF9F1D8),
      ],
      orbColors: <Color>[Color(0x99A8D5BA), Color(0x99F6D8A8)],
      ringColor: Color(0x558AB38F),
    ),
    _ChatBackgroundOption(
      name: 'Laguna',
      icon: Icons.water_drop_rounded,
      gradientColors: <Color>[
        Color(0xFFF6FCFF),
        Color(0xFFDDF3F7),
        Color(0xFFE8ECFA),
      ],
      orbColors: <Color>[Color(0x997ABCC4), Color(0x999391BC)],
      ringColor: Color(0x557ABCC4),
    ),
    _ChatBackgroundOption(
      name: 'Amanecer',
      icon: Icons.wb_sunny_rounded,
      gradientColors: <Color>[
        Color(0xFFFFFAF1),
        Color(0xFFFFE8C8),
        Color(0xFFF9D7D3),
      ],
      orbColors: <Color>[Color(0x99F2BA7B), Color(0x99E8A0A7)],
      ringColor: Color(0x55F0A15E),
    ),
    _ChatBackgroundOption(
      name: 'Nube',
      icon: Icons.bubble_chart_rounded,
      gradientColors: <Color>[
        Color(0xFFF9F7FF),
        Color(0xFFEDE9FB),
        Color(0xFFF7EFF7),
      ],
      orbColors: <Color>[Color(0x99C7BDEB), Color(0x99E3C7E4)],
      ringColor: Color(0x559391BC),
    ),
  ];

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatbotService _chatbotService = ChatbotService();
  final List<_ChatMessage> _messages = [
    const _ChatMessage(
      text:
          'Hola, soy tu chatbot de apoyo. Puedo ayudarte con orientacion inicial sobre seguridad, apoyo emocional y rutas de ayuda.',
      isUser: false,
    ),
  ];

  bool _isBotTyping = false;
  int _selectedBackgroundIndex = 0;

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
          const _ChatMessage(
            text: 'Ocurrio un error inesperado al consultar el chatbot.',
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
    final isConfigured = _chatbotService.isConfigured;
    final selectedBackground = _backgroundOptions[_selectedBackgroundIndex];

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(title: const Text('Chatbot de apoyo')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: CustomCard(
                borderRadius: 20,
                hasShadow: true,
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.pets_rounded,
                            color: AppTheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            isConfigured
                                ? 'Chat conectado a Groq (${AppConstants.groqChatModel}).'
                                : 'El chat necesita una clave de Groq para responder.',
                            style: AppTheme.titleLarge,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isConfigured
                          ? 'Personaliza el fondo del chat y conversa con una mascota guia con contexto reciente.'
                          : 'Configura GROQ_API_KEY para activar las respuestas y probar la experiencia completa.',
                      style: AppTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Fondos del chat', style: AppTheme.titleLarge),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 88,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _backgroundOptions.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final option = _backgroundOptions[index];
                        return _BackgroundOptionTile(
                          option: option,
                          isSelected: index == _selectedBackgroundIndex,
                          onTap: () {
                            setState(() {
                              _selectedBackgroundIndex = index;
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 42,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: _quickPrompts.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final prompt = _quickPrompts[index];
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
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: selectedBackground.gradientColors,
                    ),
                    borderRadius: BorderRadius.circular(28),
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
                    borderRadius: BorderRadius.circular(28),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: IgnorePointer(
                            child: _ChatBackgroundArt(
                              option: selectedBackground,
                            ),
                          ),
                        ),
                        ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                          itemCount: _messages.length + (_isBotTyping ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _messages.length) {
                              return ChatMessageBubble(
                                text: '',
                                isUser: false,
                                isTyping: true,
                                assistantAvatarUrl: _assistantAvatarUrl,
                              );
                            }

                            final message = _messages[index];
                            return ChatMessageBubble(
                              text: message.text,
                              isUser: message.isUser,
                              assistantAvatarUrl: _assistantAvatarUrl,
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
                      decoration: const InputDecoration(
                        hintText: 'Escribe tu mensaje...',
                        contentPadding: EdgeInsets.symmetric(
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

class _ChatBackgroundOption {
  final String name;
  final IconData icon;
  final List<Color> gradientColors;
  final List<Color> orbColors;
  final Color ringColor;

  const _ChatBackgroundOption({
    required this.name,
    required this.icon,
    required this.gradientColors,
    required this.orbColors,
    required this.ringColor,
  });
}

class _BackgroundOptionTile extends StatelessWidget {
  final _ChatBackgroundOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _BackgroundOptionTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 78,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.divider,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.secondary.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: option.gradientColors,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: -8,
                      right: -6,
                      child: _PreviewOrb(
                        size: 28,
                        color: option.orbColors.first,
                      ),
                    ),
                    Positioned(
                      bottom: -6,
                      left: -4,
                      child: _PreviewOrb(
                        size: 24,
                        color: option.orbColors.last,
                      ),
                    ),
                    Center(
                      child: Icon(
                        option.icon,
                        color: AppTheme.textPrimary.withValues(alpha: 0.75),
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              option.name,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textPrimary,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBackgroundArt extends StatelessWidget {
  final _ChatBackgroundOption option;

  const _ChatBackgroundArt({required this.option});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -30,
          right: -10,
          child: _PreviewOrb(size: 140, color: option.orbColors.first),
        ),
        Positioned(
          bottom: 40,
          left: -18,
          child: _PreviewOrb(size: 120, color: option.orbColors.last),
        ),
        Positioned(
          top: 140,
          left: 42,
          child: _OutlinedOrb(size: 52, color: option.ringColor),
        ),
        Positioned(
          top: 90,
          right: 58,
          child: _OutlinedOrb(size: 30, color: option.ringColor),
        ),
        Positioned(
          bottom: 150,
          right: 34,
          child: _OutlinedOrb(size: 72, color: option.ringColor),
        ),
      ],
    );
  }
}

class _PreviewOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _PreviewOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _OutlinedOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _OutlinedOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1.4),
      ),
    );
  }
}

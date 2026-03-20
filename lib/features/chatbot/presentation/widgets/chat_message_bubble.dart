import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class ChatMessageBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final bool isTyping;
  final String assistantAvatarUrl;

  const ChatMessageBubble({
    super.key,
    required this.text,
    required this.isUser,
    required this.assistantAvatarUrl,
    this.isTyping = false,
  });

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isUser ? AppTheme.primary : AppTheme.cardBg;
    final textColor = isUser ? Colors.white : AppTheme.textPrimary;
    final label = isUser ? 'Tu' : 'Mascota de apoyo';
    final bubble = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 290),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 6),
            bottomRight: Radius.circular(isUser ? 6 : 18),
          ),
          border: Border.all(
            color: isUser ? AppTheme.primaryLight : AppTheme.divider,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTheme.bodyMedium.copyWith(
                color: isUser ? Colors.white70 : AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 6),
            if (isTyping)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  3,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: EdgeInsets.only(right: index == 2 ? 0 : 6),
                    decoration: BoxDecoration(
                      color: textColor.withValues(alpha: 0.75),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              )
            else
              Text(
                text,
                style: AppTheme.bodyLarge.copyWith(
                  color: textColor,
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
          ],
        ),
      ),
    );

    if (isUser) {
      return Align(alignment: Alignment.centerRight, child: bubble);
    }

    return Padding(
      padding: const EdgeInsets.only(right: 28),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _AssistantAvatar(imageUrl: assistantAvatarUrl),
          const SizedBox(width: 10),
          Flexible(child: bubble),
        ],
      ),
    );
  }
}

class _AssistantAvatar extends StatelessWidget {
  final String imageUrl;

  const _AssistantAvatar({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.secondary.withValues(alpha: 0.16),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppTheme.primaryLight,
              alignment: Alignment.center,
              child: const Icon(
                Icons.pets_rounded,
                color: AppTheme.textPrimary,
                size: 22,
              ),
            );
          },
        ),
      ),
    );
  }
}

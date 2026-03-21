import 'package:flutter/material.dart';

import '../../../../core/localization/app_language_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/mascot_image.dart';

class ChatMessageBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final bool isTyping;

  const ChatMessageBubble({
    super.key,
    required this.text,
    required this.isUser,
    this.isTyping = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: _MessageCard(
          label: AppLanguageService.instance.pick(
            es: 'Tu',
            en: 'You',
            ay: 'Juma',
            qu: 'Qam',
          ),
          text: text,
          isTyping: isTyping,
          backgroundColor: AppTheme.primary,
          borderColor: AppTheme.primaryLight,
          textColor: AppTheme.surface,
          labelColor: AppTheme.surface.withValues(alpha: 0.72),
          maxWidth: 290,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(right: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _VirtualPetAvatar(isTyping: isTyping),
          const SizedBox(width: 10),
          Flexible(
            child: _MessageCard(
              label: isTyping
                  ? AppLanguageService.instance.pick(
                      es: 'Tu mascota esta pensando...',
                      en: 'Your pet is thinking...',
                      ay: 'Virtual mascotasamax amuyt\'aski...',
                      qu: 'Mascotayki yuyaykushan...',
                    )
                  : AppLanguageService.instance.pick(
                      es: 'Mascota virtual',
                      en: 'Virtual pet',
                      ay: 'Virtual mascota',
                      qu: 'Virtual mascota',
                    ),
              text: text,
              isTyping: isTyping,
              backgroundColor: AppTheme.cardBg,
              borderColor: AppTheme.divider,
              textColor: AppTheme.textPrimary,
              labelColor: AppTheme.textSecondary,
              maxWidth: 280,
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  final String label;
  final String text;
  final bool isTyping;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final Color labelColor;
  final double maxWidth;

  const _MessageCard({
    required this.label,
    required this.text,
    required this.isTyping,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.labelColor,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 14,
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
                color: labelColor,
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
                      color: textColor.withValues(alpha: 0.70),
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
  }
}

class _VirtualPetAvatar extends StatelessWidget {
  final bool isTyping;

  const _VirtualPetAvatar({required this.isTyping});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 74,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 66,
            height: 74,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFD7E3), Color(0xFFF8B7CB)],
              ),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.secondary.withValues(alpha: 0.14),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 10,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.34),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const Positioned.fill(
                  child: MascotImage(
                    width: 56,
                    height: 56,
                    padding: EdgeInsets.fromLTRB(6, 6, 6, 18),
                    semanticsLabel: 'Mascota virtual',
                  ),
                ),
                Positioned(
                  bottom: 7,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isTyping
                          ? AppLanguageService.instance.pick(
                              es: 'Pensando',
                              en: 'Thinking',
                              ay: 'Amuyt\'aski',
                              qu: 'Yuyaykushan',
                            )
                          : AppLanguageService.instance.pick(
                              es: 'Aqui',
                              en: 'Here',
                              ay: 'Akan',
                              qu: 'Kaypi',
                            ),
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textPrimary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppLanguageService.instance.pick(
              es: 'Compi',
              en: 'Buddy',
              ay: 'Masi',
              qu: 'Masi',
            ),
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

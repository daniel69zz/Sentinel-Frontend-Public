import 'package:flutter/material.dart';

import '../../../../core/localization/app_language_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/custom_card.dart';

class EducationEmptyState extends StatelessWidget {
  const EducationEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppTheme.accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.search_off_rounded,
              color: AppTheme.accent,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(context.tr('education.empty_title'), style: AppTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            context.tr('education.empty_subtitle'),
            style: AppTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

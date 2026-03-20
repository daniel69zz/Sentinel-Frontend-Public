import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class EducationSectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const EducationSectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTheme.titleLarge),
        const SizedBox(height: 4),
        Text(subtitle, style: AppTheme.bodyMedium),
      ],
    );
  }
}

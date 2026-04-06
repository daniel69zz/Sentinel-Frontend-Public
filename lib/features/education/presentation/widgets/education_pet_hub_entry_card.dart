import 'package:flutter/material.dart';

import '../../../../core/localization/app_language_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../../shared/widgets/mascot_image.dart';
import '../../domain/models/education_pet_state.dart';

class EducationPetHubEntryCard extends StatelessWidget {
  final EducationPetState petState;
  final bool isLoading;
  final VoidCallback onTap;

  const EducationPetHubEntryCard({
    super.key,
    required this.petState,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = isLoading
        ? context.tr('education.companion.hub_loading_subtitle')
        : petState.hasFood
        ? context.tr(
            'education.companion.hub_ready_subtitle',
            params: {
              'level': '${petState.level}',
              'food': '${petState.foodBalance}',
              'coins': '${petState.coins}',
            },
          )
        : context.tr(
            'education.companion.hub_no_food_subtitle',
            params: {'level': '${petState.level}'},
          );

    return CustomCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 52,
                height: 52,
                child: MascotImage(
                  width: 48,
                  height: 48,
                  padding: const EdgeInsets.all(4),
                  semanticsLabel: 'Mascota',
                  level: petState.level,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('education.companion.hub_title'),
                      style: AppTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle, style: AppTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            isLoading
                ? context.tr('education.companion.hub_loading_body')
                : context.tr(
                    'education.companion.hub_ready_body',
                    params: {'name': petState.name},
                  ),
            style: AppTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: Text(context.tr('education.companion.hub_button')),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/custom_card.dart';
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
        ? 'Cargando mascota y progreso...'
        : petState.hasFood
        ? 'Nivel ${petState.level} - ${petState.foodBalance} comida - ${petState.coins} monedas'
        : 'Nivel ${petState.level} - Juega para conseguir comida';

    return CustomCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.pets_rounded,
                  color: AppTheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mascota guia', style: AppTheme.titleLarge),
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
                ? 'Entra para ver su estado completo.'
                : '${petState.name} tiene su propio espacio con juegos y recompensas.',
            style: AppTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Abrir mascota y juegos'),
            ),
          ),
        ],
      ),
    );
  }
}

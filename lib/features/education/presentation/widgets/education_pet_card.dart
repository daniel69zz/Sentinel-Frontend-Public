import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../domain/models/education_pet_state.dart';

class EducationPetCard extends StatelessWidget {
  final EducationPetState petState;
  final bool isLoading;
  final bool isFeeding;
  final VoidCallback onFeed;

  const EducationPetCard({
    super.key,
    required this.petState,
    required this.isLoading,
    required this.isFeeding,
    required this.onFeed,
  });

  @override
  Widget build(BuildContext context) {
    final isBusy = isLoading || isFeeding;
    final canFeed = !isBusy && petState.hasFood;

    return CustomCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mascota de educacion', style: AppTheme.titleLarge),
                    const SizedBox(height: 6),
                    Text(
                      'Se guarda localmente en este dispositivo por ahora.',
                      style: AppTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _MoodChip(label: petState.moodLabel),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _MascotFigure(color: AppTheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      petState.name,
                      style: AppTheme.headlineMedium.copyWith(fontSize: 24),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Nivel ${petState.level}',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.primaryLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(petState.statusMessage, style: AppTheme.bodyLarge),
                    const SizedBox(height: 14),
                    Text(
                      '${petState.currentXp}/${EducationPetState.xpPerLevel} XP',
                      style: AppTheme.labelLarge.copyWith(fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    _XpBar(progress: petState.progress),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _PetStatPill(
                icon: Icons.auto_awesome_rounded,
                label: 'XP total',
                value: '${petState.totalXp}',
              ),
              _PetStatPill(
                icon: Icons.restaurant_rounded,
                label: 'Comida',
                value: '${petState.foodBalance}',
              ),
              _PetStatPill(
                icon: Icons.monetization_on_rounded,
                label: 'Monedas',
                value: '${petState.coins}',
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: canFeed ? onFeed : null,
              icon: Icon(
                isFeeding
                    ? Icons.hourglass_top_rounded
                    : Icons.restaurant_menu_rounded,
              ),
              label: Text(
                isLoading
                    ? 'Cargando mascota...'
                    : isFeeding
                    ? 'Alimentando...'
                    : petState.hasFood
                    ? 'Alimentar -1 comida / +${EducationPetState.xpPerMeal} XP'
                    : 'Sin comida disponible',
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            petState.hasFood
                ? petState.lastFedLabel
                : 'Juega para conseguir comida y seguir subiendo XP.',
            style: AppTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _MascotFigure extends StatelessWidget {
  final Color color;

  const _MascotFigure({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104,
      height: 136,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.90),
            color.withValues(alpha: 0.45),
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: color.withValues(alpha: 0.26)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 16,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            child: Icon(
              Icons.pets_rounded,
              size: 54,
              color: Colors.white.withValues(alpha: 0.95),
            ),
          ),
          const Positioned(
            top: 18,
            right: 14,
            child: Icon(
              Icons.favorite_rounded,
              size: 18,
              color: AppTheme.accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _MoodChip extends StatelessWidget {
  final String label;

  const _MoodChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.24)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppTheme.primaryLight,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PetStatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _PetStatPill({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.textSecondary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTheme.bodyMedium.copyWith(fontSize: 12)),
              const SizedBox(height: 2),
              Text(value, style: AppTheme.labelLarge.copyWith(fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }
}

class _XpBar extends StatelessWidget {
  final double progress;

  const _XpBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 12,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: progress,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.accent, AppTheme.primaryLight],
              ),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
      ),
    );
  }
}

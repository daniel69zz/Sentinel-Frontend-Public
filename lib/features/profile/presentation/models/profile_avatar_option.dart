import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/app_theme.dart';

class ProfileAvatarOption {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color startColor;
  final Color endColor;

  const ProfileAvatarOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.startColor,
    required this.endColor,
  });
}

class ProfileAppearanceStore {
  static const String _avatarPreferenceKey = 'profile_avatar_option';

  static const List<ProfileAvatarOption> avatarOptions = [
    ProfileAvatarOption(
      id: 'agenda_soft',
      title: 'Agenda',
      subtitle: 'Vista discreta y ordenada.',
      icon: Icons.calendar_month_rounded,
      startColor: Color(0xFF1B9AAA),
      endColor: Color(0xFF4FC3D8),
    ),
    ProfileAvatarOption(
      id: 'notas_soft',
      title: 'Notas',
      subtitle: 'Simple y bastante neutral.',
      icon: Icons.sticky_note_2_rounded,
      startColor: Color(0xFFF28F3B),
      endColor: Color(0xFFF7B267),
    ),
    ProfileAvatarOption(
      id: 'tareas_soft',
      title: 'Lista',
      subtitle: 'Una opcion generica tipo pendientes.',
      icon: Icons.checklist_rounded,
      startColor: Color(0xFF2E9E57),
      endColor: Color(0xFF69C88B),
    ),
    ProfileAvatarOption(
      id: 'lectura_soft',
      title: 'Lectura',
      subtitle: 'Perfil sobrio con tono de cuaderno.',
      icon: Icons.menu_book_rounded,
      startColor: Color(0xFF8B6F47),
      endColor: Color(0xFFB08968),
    ),
    ProfileAvatarOption(
      id: 'bienestar_soft',
      title: 'Bienestar',
      subtitle: 'Toque amable y cotidiano.',
      icon: Icons.spa_rounded,
      startColor: AppTheme.primary,
      endColor: AppTheme.primaryLight,
    ),
    ProfileAvatarOption(
      id: 'clima_soft',
      title: 'Clima',
      subtitle: 'Icono neutro para pasar desapercibido.',
      icon: Icons.cloud_rounded,
      startColor: Color(0xFF6C8CBF),
      endColor: Color(0xFF95A8D7),
    ),
  ];

  static ProfileAvatarOption optionById(String? id) {
    return avatarOptions.firstWhere(
      (option) => option.id == id,
      orElse: () => avatarOptions.first,
    );
  }

  static Future<String> loadAvatarOptionId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_avatarPreferenceKey) ?? avatarOptions.first.id;
  }

  static Future<void> saveAvatarOptionId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_avatarPreferenceKey, optionById(id).id);
  }
}

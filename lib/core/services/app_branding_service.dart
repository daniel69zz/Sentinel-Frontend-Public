import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../localization/app_language_service.dart';
import '../theme/app_theme.dart';

@immutable
class AppBrandingPreset {
  final String id;
  final String launcherName;
  final String title;
  final String description;
  final IconData previewIcon;
  final Color accentColor;

  const AppBrandingPreset({
    required this.id,
    required this.launcherName,
    required this.title,
    required this.description,
    required this.previewIcon,
    required this.accentColor,
  });
}

class AppBrandingService extends ChangeNotifier {
  AppBrandingService._();

  static final AppBrandingService instance = AppBrandingService._();
  static const MethodChannel _channel = MethodChannel(
    'com.example.test01/app_branding',
  );

  static const List<AppBrandingPreset> presets = [
    AppBrandingPreset(
      id: 'sentinel',
      launcherName: AppConstants.appName,
      title: 'Sentinel',
      description: 'Mantiene la identidad actual de seguridad.',
      previewIcon: Icons.shield_rounded,
      accentColor: AppTheme.primary,
    ),
    AppBrandingPreset(
      id: 'agenda',
      launcherName: 'Agenda',
      title: 'Agenda',
      description: 'Aspecto discreto, como una app de calendario.',
      previewIcon: Icons.calendar_month_rounded,
      accentColor: AppTheme.roseDust,
    ),
    AppBrandingPreset(
      id: 'notas',
      launcherName: 'Notas',
      title: 'Notas',
      description: 'Icono limpio para pasar como bloc de notas.',
      previewIcon: Icons.sticky_note_2_rounded,
      accentColor: AppTheme.warning,
    ),
    AppBrandingPreset(
      id: 'tareas',
      launcherName: 'Tareas',
      title: 'Tareas',
      description: 'Lista de pendientes simple y neutral.',
      previewIcon: Icons.checklist_rounded,
      accentColor: AppTheme.accent,
    ),
  ];

  AppBrandingPreset _selectedPreset = presetById(
    AppConstants.defaultBrandingPresetId,
  );
  String _customAppName = '';

  AppBrandingPreset get selectedPreset => _selectedPreset;
  String get customAppName => _customAppName;
  String get displayName =>
      _customAppName.isEmpty ? _selectedPreset.launcherName : _customAppName;
  bool get supportsLauncherCustomization =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static AppBrandingPreset presetById(String? id) {
    return presets.firstWhere(
      (preset) => preset.id == id,
      orElse: () => presets.first,
    );
  }

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedPreset = presetById(
      prefs.getString(AppConstants.keyBrandingPreset),
    );
    _customAppName = _sanitizeName(
      prefs.getString(AppConstants.keyCustomAppName) ?? '',
    );

    if (supportsLauncherCustomization) {
      await _applyNativePreset(_selectedPreset.id);
    }
  }

  Future<String?> saveBranding({
    required String presetId,
    required String customAppName,
  }) async {
    _selectedPreset = presetById(presetId);
    _customAppName = _sanitizeName(customAppName);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyBrandingPreset, _selectedPreset.id);
    await prefs.setString(AppConstants.keyCustomAppName, _customAppName);

    return _applyNativePreset(_selectedPreset.id);
  }

  String _sanitizeName(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  Future<String?> _applyNativePreset(String presetId) async {
    if (!supportsLauncherCustomization) {
      return AppLanguageService.instance.tr(
        'profile.appearance.platform_android',
      );
    }

    try {
      await _channel.invokeMethod<void>('applyPreset', {'presetId': presetId});
      return null;
    } on MissingPluginException {
      return AppLanguageService.instance.tr(
        'profile.appearance.native_connection_error',
        fallback: 'No se pudo conectar con el cambio nativo del launcher.',
      );
    } on PlatformException catch (error) {
      return error.message ??
          AppLanguageService.instance.tr(
            'profile.appearance.native_update_error',
            fallback: 'No se pudo actualizar el launcher.',
          );
    } catch (_) {
      return AppLanguageService.instance.tr(
        'profile.appearance.native_update_error',
        fallback: 'No se pudo actualizar el launcher.',
      );
    }
  }
}

extension AppBrandingPresetLocalization on AppBrandingPreset {
  String get localizedTitle {
    return AppLanguageService.instance.tr(
      'profile.branding.$id.title',
      fallback: title,
    );
  }

  String get localizedDescription {
    return AppLanguageService.instance.tr(
      'profile.branding.$id.description',
      fallback: description,
    );
  }
}

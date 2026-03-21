import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum AppLanguage {
  spanish(
    code: 'es',
    labelKey: 'languages.spanish',
    materialLocale: Locale('es', 'BO'),
    chatbotName: 'Spanish',
  );

  final String code;
  final String labelKey;
  final Locale materialLocale;
  final String chatbotName;

  const AppLanguage({
    required this.code,
    required this.labelKey,
    required this.materialLocale,
    required this.chatbotName,
  });

  static AppLanguage fromCode(String? value) => AppLanguage.spanish;
}

class AppLanguageService extends ChangeNotifier {
  AppLanguageService._();

  static final AppLanguageService instance = AppLanguageService._();
  static const String _assetPathPrefix = 'assets/i18n';
  static const List<Locale> supportedMaterialLocales = [Locale('es', 'BO')];

  AppLanguage _language = AppLanguage.spanish;
  Map<String, dynamic> _translations = <String, dynamic>{};
  Map<String, dynamic> _fallbackTranslations = <String, dynamic>{};

  AppLanguage get language => _language;
  Locale get materialLocale => _language.materialLocale;

  Future<void> initialize() async {
    _language = AppLanguage.spanish;
    _translations = await _loadTranslations(_language);
    _fallbackTranslations = _translations;
  }

  Future<void> setLanguage(AppLanguage language) async {}

  String languageLabel(AppLanguage language) {
    return tr(language.labelKey);
  }

  String pick({
    required String es,
    String? en,
    String? ay,
    String? qu,
  }) {
    return es;
  }

  String tr(
    String key, {
    Map<String, String> params = const <String, String>{},
    String? fallback,
  }) {
    final value =
        _lookupValue(_translations, key) ??
        _lookupValue(_fallbackTranslations, key) ??
        fallback ??
        key;

    if (value is! String) {
      return fallback ?? key;
    }

    return _replaceParams(value, params);
  }

  Future<Map<String, dynamic>> _loadTranslations(AppLanguage language) async {
    try {
      final raw = await rootBundle.loadString(
        '$_assetPathPrefix/${language.code}.json',
      );
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {
      // Fall back to the bundled Spanish copy.
    }

    return _fallbackTranslations;
  }

  dynamic _lookupValue(Map<String, dynamic> source, String key) {
    dynamic current = source;
    for (final part in key.split('.')) {
      if (current is Map<String, dynamic> && current.containsKey(part)) {
        current = current[part];
        continue;
      }
      if (current is Map && current.containsKey(part)) {
        current = current[part];
        continue;
      }
      return null;
    }
    return current;
  }

  String _replaceParams(String value, Map<String, String> params) {
    var resolved = value;
    for (final entry in params.entries) {
      resolved = resolved.replaceAll('{{${entry.key}}}', entry.value);
    }
    return resolved;
  }
}

extension AppLanguageBuildContext on BuildContext {
  AppLanguage get appLanguage => AppLanguageService.instance.language;

  String tr(
    String key, {
    Map<String, String> params = const <String, String>{},
    String? fallback,
  }) {
    return AppLanguageService.instance.tr(
      key,
      params: params,
      fallback: fallback,
    );
  }
}

class AppConstants {
  // App Info
  static const String appName = 'Sentinel';
  static const String appVersion = '1.0.0';
  static const String defaultBrandingPresetId = 'sentinel';
  static const String groqApiKey = String.fromEnvironment('GROQ_API_KEY');
  static const String groqChatModel = String.fromEnvironment(
    'GROQ_CHAT_MODEL',
    defaultValue: 'llama-3.3-70b-versatile',
  );
  static const String groqApiBaseUrl = String.fromEnvironment(
    'GROQ_API_BASE_URL',
    defaultValue: 'https://api.groq.com/openai/v1',
  );

  // Backend
  static String get backendBaseUrl {
    const configuredUrl = String.fromEnvironment(
      'BACKEND_URL',
      defaultValue: '',
    );
    if (configuredUrl.isNotEmpty) {
      return configuredUrl;
    }

    return 'http://144.22.43.169:3000';
  }

  // Emergency
  static const String emergencyNumber = '800-10-0200';
  static const String policeNumber = '110';
  static const String ambulanceNumber = '118';

  // Assets
  static const String logoPath = 'assets/images/logo.png';
  static const String mascotPath = 'assets/images/Mascota/mascota_stage1.png';
  static const List<String> mascotLevelPaths = [
    'assets/images/Mascota/mascota_stage1.png',
    'assets/images/Mascota/mascota_stage2.png',
    'assets/images/Mascota/mascota_stage3.png',
    'assets/images/Mascota/mascota_stage4.png',
  ];

  static String mascotForLevel(int level) {
    if (level <= 1) return mascotLevelPaths[0];
    if (level == 2) return mascotLevelPaths[1];
    if (level == 3) return mascotLevelPaths[2];
    return mascotLevelPaths.last;
  }

  // Shared Preferences Keys
  static const String keyOnboarded = 'onboarded';
  static const String keyUserName = 'user_name';
  static const String keyEmergencyContacts = 'emergency_contacts';
  static const String keyUserPhone = 'user_phone';
  static const String keyBrandingPreset = 'branding_preset';
  static const String keyCustomAppName = 'custom_app_name';
  static const String keyAppTheme = 'app_theme_mode';

  // Durations
  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration snackbarDuration = Duration(seconds: 3);
  static const Duration panicCountdown = Duration(seconds: 3);
}

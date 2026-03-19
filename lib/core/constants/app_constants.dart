class AppConstants {
  // App Info
  static const String appName = 'Sentinel';
  static const String appVersion = '1.0.0';

  // Emergency
  static const String emergencyNumber = '800-10-0200'; // Bolivia línea violencia
  static const String policeNumber = '110';
  static const String ambulanceNumber = '118';

  // Assets
  static const String logoPath = 'assets/images/logo.png';

  // Shared Preferences Keys
  static const String keyOnboarded = 'onboarded';
  static const String keyUserName = 'user_name';
  static const String keyEmergencyContacts = 'emergency_contacts';
  static const String keyUserPhone = 'user_phone';

  // Durations
  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration snackbarDuration = Duration(seconds: 3);
  static const Duration panicCountdown = Duration(seconds: 3);
}

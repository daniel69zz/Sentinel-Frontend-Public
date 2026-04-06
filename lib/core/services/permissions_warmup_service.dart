import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PermissionsWarmupResult {
  final bool cameraGranted;
  final bool microphoneGranted;
  final bool storageGranted;
  final bool locationGranted;
  final bool locationServiceEnabled;

  const PermissionsWarmupResult({
    required this.cameraGranted,
    required this.microphoneGranted,
    required this.storageGranted,
    required this.locationGranted,
    required this.locationServiceEnabled,
  });

  bool get allGranted =>
      cameraGranted &&
      microphoneGranted &&
      storageGranted &&
      locationGranted &&
      locationServiceEnabled;

  List<String> get missing {
    final items = <String>[];
    if (!cameraGranted) items.add('camara');
    if (!microphoneGranted) items.add('microfono');
    if (!storageGranted) items.add('almacenamiento');
    if (!locationGranted || !locationServiceEnabled) items.add('ubicacion');
    return items;
  }
}

class PermissionsWarmupService {
  static const String _prefsKey = 'permissions_warmup_v1';
  static final PermissionsWarmupService instance = PermissionsWarmupService._();

  PermissionsWarmupService._();

  Future<bool> _wasRequested() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefsKey) ?? false;
  }

  Future<void> _markRequested() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, true);
  }

  /// Requests camera, microphone and location up front so that the SOS flow
  /// does not get blocked later. Set [forcePrompt] to true to show the dialogs
  /// again even if the user has already seen them.
  Future<PermissionsWarmupResult> requestCriticalPermissions({
    bool forcePrompt = false,
  }) async {
    final shouldPrompt = forcePrompt || !(await _wasRequested());

    final cameraStatus = shouldPrompt
        ? await Permission.camera.request()
        : await Permission.camera.status;
    final microphoneStatus = shouldPrompt
        ? await Permission.microphone.request()
        : await Permission.microphone.status;
    final storageStatus = shouldPrompt
        ? await Permission.storage.request()
        : await Permission.storage.status;

    final locationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    final locationStatus = shouldPrompt
        ? await Permission.locationWhenInUse.request()
        : await Permission.locationWhenInUse.status;

    if (shouldPrompt) {
      await _markRequested();
    }

    return PermissionsWarmupResult(
      cameraGranted: cameraStatus.isGranted || cameraStatus.isLimited,
      microphoneGranted:
          microphoneStatus.isGranted || microphoneStatus.isLimited,
      storageGranted: storageStatus.isGranted || storageStatus.isLimited,
      locationGranted: locationStatus.isGranted || locationStatus.isLimited,
      locationServiceEnabled: locationServiceEnabled,
    );
  }

  Future<void> openSystemSettings() async {
    await openAppSettings();
  }
}

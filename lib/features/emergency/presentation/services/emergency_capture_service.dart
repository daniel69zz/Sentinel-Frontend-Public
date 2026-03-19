import 'dart:io';

import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class EmergencyCaptureResult {
  final bool videoStarted;
  final bool audioStarted;
  final Position? position;
  final String? videoPath;
  final String? audioPath;
  final List<String> issues;

  const EmergencyCaptureResult({
    required this.videoStarted,
    required this.audioStarted,
    required this.position,
    required this.videoPath,
    required this.audioPath,
    required this.issues,
  });

  bool get hasAnyAction => videoStarted || audioStarted || position != null;

  String? get mapsUrl {
    final current = position;
    if (current == null) return null;
    return 'https://maps.google.com/?q=${current.latitude},${current.longitude}';
  }
}

class EmergencyCaptureService {
  CameraController? _cameraController;
  AudioRecorder? _audioRecorder;

  Future<EmergencyCaptureResult> startEmergencyCapture() async {
    final issues = <String>[];
    var videoStarted = false;
    var audioStarted = false;
    String? videoPath;
    String? audioPath;
    Position? position;

    final cameraGranted = await _requestPermission(Permission.camera);
    final microphoneGranted = await _requestPermission(Permission.microphone);
    final locationGranted = await _requestLocationPermission();

    if (!cameraGranted) {
      issues.add('Sin permiso de cámara.');
    }
    if (!microphoneGranted) {
      issues.add('Sin permiso de micrófono.');
    }
    if (!locationGranted) {
      issues.add('Sin permiso de ubicación.');
    }

    final sessionDirectory = await _createSessionDirectory();

    if (cameraGranted) {
      try {
        final cameras = await availableCameras();
        final selectedCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.back,
          orElse: () => cameras.first,
        );

        final controller = CameraController(
          selectedCamera,
          ResolutionPreset.medium,
          enableAudio: false,
        );

        await controller.initialize();
        if (Platform.isIOS) {
          await controller.prepareForVideoRecording();
        }

        videoPath = p.join(sessionDirectory.path, 'sos_video.mp4');
        await controller.startVideoRecording();
        _cameraController = controller;
        videoStarted = true;
      } catch (_) {
        issues.add('No se pudo iniciar la grabación de video.');
      }
    }

    if (microphoneGranted) {
      try {
        final recorder = AudioRecorder();
        audioPath = p.join(sessionDirectory.path, 'sos_audio.m4a');
        await recorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: audioPath,
        );
        _audioRecorder = recorder;
        audioStarted = true;
      } catch (_) {
        issues.add('No se pudo iniciar la grabación de audio.');
      }
    }

    if (locationGranted) {
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );
      } catch (_) {
        issues.add('No se pudo obtener la ubicación actual.');
      }
    }

    return EmergencyCaptureResult(
      videoStarted: videoStarted,
      audioStarted: audioStarted,
      position: position,
      videoPath: videoPath,
      audioPath: audioPath,
      issues: issues,
    );
  }

  Future<void> stopEmergencyCapture() async {
    try {
      final controller = _cameraController;
      if (controller != null) {
        if (controller.value.isRecordingVideo) {
          await controller.stopVideoRecording();
        }
        await controller.dispose();
      }
    } catch (_) {
      // Keep emergency teardown resilient.
    } finally {
      _cameraController = null;
    }

    try {
      final recorder = _audioRecorder;
      if (recorder != null) {
        if (await recorder.isRecording()) {
          await recorder.stop();
        }
        await recorder.dispose();
      }
    } catch (_) {
      // Keep emergency teardown resilient.
    } finally {
      _audioRecorder = null;
    }
  }

  Future<bool> _requestPermission(Permission permission) async {
    final status = await permission.request();
    return status.isGranted || status.isLimited;
  }

  Future<bool> _requestLocationPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    final status = await Permission.locationWhenInUse.request();
    return status.isGranted || status.isLimited;
  }

  Future<Directory> _createSessionDirectory() async {
    final baseDirectory = await getTemporaryDirectory();
    final sessionDirectory = Directory(
      p.join(
        baseDirectory.path,
        'emergency_${DateTime.now().millisecondsSinceEpoch}',
      ),
    );

    if (!await sessionDirectory.exists()) {
      await sessionDirectory.create(recursive: true);
    }

    return sessionDirectory;
  }
}

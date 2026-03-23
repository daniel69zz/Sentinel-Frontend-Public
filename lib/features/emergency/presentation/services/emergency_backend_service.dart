import 'dart:io';

import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;

import '../../../../core/localization/app_language_service.dart';
import '../../../../core/services/app_branding_service.dart';
import '../../../auth/presentation/services/auth_service.dart';
import '../../../evidence/presentation/services/evidence_service.dart';
import 'emergency_capture_service.dart';

class EmergencyEvidenceUploadResult {
  final bool success;
  final int uploadedCount;
  final List<String> evidenceIds;
  final String? message;

  const EmergencyEvidenceUploadResult({
    required this.success,
    required this.uploadedCount,
    this.evidenceIds = const [],
    this.message,
  });
}

class EmergencyBackendService {
  final AuthService _authService;
  final EvidenceService _evidenceService;

  EmergencyBackendService({
    AuthService? authService,
    EvidenceService? evidenceService,
  }) : _authService = authService ?? AuthService(),
       _evidenceService = evidenceService ?? EvidenceService();

  String _t({
    required String es,
    required String en,
    required String ay,
    required String qu,
  }) {
    return AppLanguageService.instance.pick(
      es: es,
      en: en,
      ay: ay,
      qu: qu,
    );
  }

  Future<EmergencyEvidenceUploadResult> uploadEvidence({
    required EmergencyCaptureStopResult stopResult,
    String? locationUrl,
    DateTime? alertTriggeredAt,
  }) async {
    final attachmentPaths = stopResult.attachmentPaths;
    if (attachmentPaths.isEmpty) {
      return EmergencyEvidenceUploadResult(
        success: false,
        uploadedCount: 0,
        message: _t(
          es: 'No habia archivos para subir al servidor.',
          en: 'There were no files to upload to the server.',
          ay: 'Janiw servidorar apkatanatakix archivos utjkiti.',
          qu: 'Servidorman wicharinapaq archivosqa mana karqanchu.',
        ),
      );
    }

    final user = await _authService.getSession();
    if (user == null) {
      return EmergencyEvidenceUploadResult(
        success: false,
        uploadedCount: 0,
        message: _t(
          es: 'No hay una sesion activa para subir evidencia.',
          en: 'There is no active session to upload evidence.',
          ay: 'Janiw evidencia apkatanatakix sesion activa utjkiti.',
          qu: 'Evidencia wicharinapaq sesion activaqa mana kanchu.',
        ),
      );
    }

    final triggeredAt = alertTriggeredAt ?? DateTime.now();
    var uploadedCount = 0;
    final issues = <String>[];
    final evidenceIds = <String>[];

    for (final filePath in attachmentPaths) {
      final file = File(filePath);
      if (!await file.exists()) {
        issues.add(
          _t(
            es: 'No se encontro ${p.basename(filePath)}.',
            en: '${p.basename(filePath)} was not found.',
            ay: '${p.basename(filePath)} janiw jikxataskiti.',
            qu: '${p.basename(filePath)} mana tarikurqanchu.',
          ),
        );
        continue;
      }

      final mimeType = lookupMimeType(filePath) ?? _fallbackMimeType(filePath);
      final evidenceType = _inferEvidenceType(mimeType);
      if (mimeType == null || evidenceType == null) {
        issues.add(
          _t(
            es: 'No se pudo reconocer el tipo de ${p.basename(filePath)}.',
            en: 'The type of ${p.basename(filePath)} could not be recognized.',
            ay: '${p.basename(filePath)} ukax kuna kasta uk janiw untayaskiti.',
            qu:
                '${p.basename(filePath)} ima kastachus mana reqsiyta atikurqanchu.',
          ),
        );
        continue;
      }

      try {
        final takenAt = await file.lastModified();
        final evidenceTitle = _buildEvidenceTitle(
          evidenceType: evidenceType,
          triggeredAt: triggeredAt,
        );
        final evidenceDescription = _buildEvidenceDescription(
          evidenceType: evidenceType,
          locationUrl: locationUrl,
        );
        final createResult = await _evidenceService.createEvidence(
          filePath: filePath,
          selectedType: evidenceType,
          title: evidenceTitle,
          description: evidenceDescription,
          takenAt: takenAt,
          isPrivate: true,
        );

        if (!createResult.success || createResult.evidence == null) {
          issues.add('${p.basename(filePath)}: ${createResult.message}');
          continue;
        }

        final storedEvidence = createResult.evidence!;
        uploadedCount++;
        if (storedEvidence.id.trim().isNotEmpty) {
          evidenceIds.add(storedEvidence.id);
        }

        await _evidenceService.upsertCachedEvidence(
          userId: user.id,
          evidence: storedEvidence.copyWith(
            title: evidenceTitle,
            description: evidenceDescription,
          ),
        );
      } catch (_) {
        issues.add(
          _t(
            es: 'No se pudo subir ${p.basename(filePath)}.',
            en: '${p.basename(filePath)} could not be uploaded.',
            ay: 'Janiw ${p.basename(filePath)} apkatanjamakiti.',
            qu: '${p.basename(filePath)} mana wichariyta atikurqanchu.',
          ),
        );
      }
    }

    return EmergencyEvidenceUploadResult(
      success: uploadedCount > 0,
      uploadedCount: uploadedCount,
      evidenceIds: evidenceIds,
      message: _buildUploadMessage(
        uploadedCount: uploadedCount,
        issues: issues,
      ),
    );
  }

  String _buildEvidenceTitle({
    required String evidenceType,
    required DateTime triggeredAt,
  }) {
    final timestamp = _formatAlertTimestamp(triggeredAt);
    final typeLabel = switch (evidenceType) {
      'video' => _t(
        es: 'Video SOS',
        en: 'SOS Video',
        ay: 'SOS Video',
        qu: 'SOS Video',
      ),
      'audio' => _t(
        es: 'Audio SOS',
        en: 'SOS Audio',
        ay: 'SOS Audio',
        qu: 'SOS Audio',
      ),
      'imagen' => _t(
        es: 'Imagen SOS',
        en: 'SOS Image',
        ay: 'SOS Imagen',
        qu: 'SOS Imagen',
      ),
      _ => _t(
        es: 'Evidencia SOS',
        en: 'SOS Evidence',
        ay: 'SOS Evidencia',
        qu: 'SOS Evidencia',
      ),
    };
    return '$typeLabel - $timestamp';
  }

  String _buildEvidenceDescription({
    required String evidenceType,
    String? locationUrl,
  }) {
    final typeLabel = switch (evidenceType) {
      'video' => _t(
        es: 'Video registrado durante la alerta SOS.',
        en: 'Video recorded during the SOS alert.',
        ay: 'SOS alerta pachan qillqtata video.',
        qu: 'SOS alerta pachapi qillqasqa video.',
      ),
      'audio' => _t(
        es: 'Audio registrado durante la alerta SOS.',
        en: 'Audio recorded during the SOS alert.',
        ay: 'SOS alerta pachan qillqtata audio.',
        qu: 'SOS alerta pachapi qillqasqa audio.',
      ),
      'imagen' => _t(
        es: 'Imagen registrada durante la alerta SOS.',
        en: 'Image recorded during the SOS alert.',
        ay: 'SOS alerta pachan qillqtata imagen.',
        qu: 'SOS alerta pachapi qillqasqa imagen.',
      ),
      _ => _t(
        es: 'Evidencia registrada durante la alerta SOS.',
        en: 'Evidence recorded during the SOS alert.',
        ay: 'SOS alerta pachan qillqtata evidencia.',
        qu: 'SOS alerta pachapi qillqasqa evidencia.',
      ),
    };

    if (locationUrl == null || locationUrl.trim().isEmpty) {
      return typeLabel;
    }

    return '$typeLabel ${_t(
      es: 'Ubicacion asociada: $locationUrl',
      en: 'Linked location: $locationUrl',
      ay: 'Mayachata ubicacion: $locationUrl',
      qu: 'Tinkisqa ubicacion: $locationUrl',
    )}';
  }

  String? _fallbackMimeType(String filePath) {
    final extension = p.extension(filePath).toLowerCase();
    switch (extension) {
      case '.mp4':
        return 'video/mp4';
      case '.m4a':
        return 'audio/mp4';
      case '.aac':
        return 'audio/aac';
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      default:
        return null;
    }
  }

  String? _inferEvidenceType(String? mimeType) {
    if (mimeType == null || mimeType.isEmpty) {
      return null;
    }

    if (mimeType.startsWith('video/')) {
      return 'video';
    }

    if (mimeType.startsWith('audio/')) {
      return 'audio';
    }

    if (mimeType.startsWith('image/')) {
      return 'imagen';
    }

    return null;
  }

  String _buildUploadMessage({
    required int uploadedCount,
    required List<String> issues,
  }) {
    final appName = AppBrandingService.instance.displayName;
    if (uploadedCount == 0 && issues.isEmpty) {
      return _t(
        es: 'No se pudo subir evidencia al servidor.',
        en: 'The evidence could not be uploaded to the server.',
        ay: 'Janiw evidencia servidorar apkatanjamakiti.',
        qu: 'Evidenciaqa servidorman mana wichariyta atikurqanchu.',
      );
    }

    if (uploadedCount == 0) {
      return '${_t(
        es: 'No se pudo subir la evidencia al servidor.',
        en: 'The evidence could not be uploaded to the server.',
        ay: 'Janiw evidencia servidorar apkatanjamakiti.',
        qu: 'Evidenciaqa servidorman mana wichariyta atikurqanchu.',
      )} ${issues.first}';
    }

    if (issues.isEmpty) {
      return uploadedCount == 1
          ? _t(
              es: 'La evidencia se subio al servidor $appName.',
              en: 'The evidence was uploaded to the $appName server.',
              ay: 'Evidenciax $appName servidorar apkatawa.',
              qu: 'Evidenciaqa $appName servidorman wicharisqa karqan.',
            )
          : _t(
              es: 'Se subieron $uploadedCount archivos al servidor $appName.',
              en: '$uploadedCount files were uploaded to the $appName server.',
              ay: '$uploadedCount archivonakax $appName servidorar apkatatawa.',
              qu:
                  '$uploadedCount archivosqa $appName servidorman wicharisqa karqanku.',
            );
    }

    return '${_t(
      es: 'Se subieron $uploadedCount archivos al servidor.',
      en: '$uploadedCount files were uploaded to the server.',
      ay: '$uploadedCount archivonakax servidorar apkatatawa.',
      qu: '$uploadedCount archivosqa servidorman wicharisqa karqanku.',
    )} ${issues.first}';
  }

  String _formatAlertTimestamp(DateTime value) {
    final local = value.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString().padLeft(4, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }
}

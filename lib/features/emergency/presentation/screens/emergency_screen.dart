import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/localization/app_language_service.dart';
import '../../../../core/theme/app_design_theme.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../auth/presentation/services/auth_service.dart';
import '../../../auth/presentation/services/contacts_service.dart';
import '../services/emergency_alert_service.dart';
import '../services/emergency_backend_service.dart';
import '../services/emergency_capture_service.dart';
import '../widgets/panic_button.dart';

class EmergencyScreen extends StatefulWidget {
  final bool isEmbedded;

  const EmergencyScreen({super.key, this.isEmbedded = false});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  bool _isRecording = false;
  bool _isSendingAlert = false;
  bool _isProcessingEvidence = false;
  String _captureStatus = AppLanguageService.instance.tr(
    'emergency.capture_recording_all',
  );
  String? _processingStatus;
  String? _activeLocationUrl;
  String? _activeIncidentId;
  DateTime? _activeAlertTriggeredAt;
  Future<EmergencyIncidentResult>? _incidentCreationFuture;

  final AuthService _authService = AuthService();
  final ContactsService _contactsService = ContactsService();
  final EmergencyCaptureService _captureService = EmergencyCaptureService();
  final EmergencyAlertService _alertService = EmergencyAlertService();
  final EmergencyBackendService _backendService = EmergencyBackendService();

  Future<void> _activateAlert() async {
    if (_isRecording) return;

    final triggeredAt = DateTime.now();
    final capture = await _captureService.startEmergencyCapture();
    if (!mounted) return;

    if (!capture.hasAnyAction) {
      for (final issue in capture.issues) {
        _showSnackBar(issue);
      }
      return;
    }

    _activeLocationUrl = capture.mapsUrl;
    _activeAlertTriggeredAt = triggeredAt;

    setState(() {
      _isRecording = true;
      _captureStatus = _buildCaptureStatus(capture);
    });

    for (final issue in capture.issues) {
      _showSnackBar(issue);
    }

    _incidentCreationFuture = _backendService.createIncident(
      locationUrl: capture.mapsUrl,
      alertTriggeredAt: triggeredAt,
    );
    unawaited(_rememberIncidentId(_incidentCreationFuture!));
    unawaited(
      _sendEmergencyAlert(
        locationUrl: capture.mapsUrl,
        alertTriggeredAt: triggeredAt,
      ),
    );
    _showAlertDialog();
  }

  Future<void> _deactivateAlert() async {
    if (_isProcessingEvidence) return;

    setState(() {
      _isProcessingEvidence = true;
      _processingStatus = AppLanguageService.instance.tr(
        'emergency.processing_save_close',
      );
    });

    EmergencyCaptureStopResult? stopResult;
    String? locationUrl;
    final pendingIncidentFuture = _incidentCreationFuture;
    final previousLocationUrl = _activeLocationUrl;
    final previousAlertTriggeredAt = _activeAlertTriggeredAt;
    _activeLocationUrl = null;
    _activeAlertTriggeredAt = null;
    _incidentCreationFuture = null;

    try {
      stopResult = await _captureService.stopEmergencyCapture();
      locationUrl = stopResult.mapsUrl ?? previousLocationUrl;

      if (!mounted) return;
      setState(() => _isRecording = false);

      for (final issue in stopResult.issues) {
        _showSnackBar(issue);
      }

      setState(() {
        _processingStatus = AppLanguageService.instance.tr(
          'emergency.processing_prepare_email',
          fallback: 'Preparando evidencia para correo o compartir...',
        );
      });

      final shareResult = await _alertService.shareEvidence(
        stopResult: stopResult,
        locationUrl: locationUrl,
        alertTriggeredAt: previousAlertTriggeredAt,
      );

      if (mounted && shareResult.message != null) {
        _showSnackBar(shareResult.message!);
      }

      final hasEvidence = stopResult.attachmentPaths.isNotEmpty;
      if (hasEvidence) {
        setState(() {
          _processingStatus = AppLanguageService.instance.tr(
            'emergency.processing_upload',
          );
        });
      }

      final incidentId = await _resolveIncidentId(
        locationUrl: locationUrl,
        pendingIncidentFuture: pendingIncidentFuture,
        alertTriggeredAt: previousAlertTriggeredAt,
      );

      if (hasEvidence) {
        final uploadResult = await _backendService.uploadEvidence(
          incidentId: incidentId,
          stopResult: stopResult,
          locationUrl: locationUrl,
        );

        if (mounted && uploadResult.message != null) {
          _showSnackBar(uploadResult.message!);
        }
      }
    } finally {
      _activeIncidentId = null;
      if (mounted) {
        setState(() {
          _isProcessingEvidence = false;
          _processingStatus = null;
        });
      }
    }
  }

  Future<void> _sendEmergencyAlert({
    String? locationUrl,
    DateTime? alertTriggeredAt,
  }) async {
    if (_isSendingAlert) return;

    setState(() => _isSendingAlert = true);

    try {
      final result = await _alertService.sendLocationAlert(
        locationUrl: locationUrl,
        alertTriggeredAt: alertTriggeredAt ?? _activeAlertTriggeredAt,
      );

      if (mounted && result.message != null) {
        _showSnackBar(result.message!);
      }
    } catch (_) {
      _showSnackBar(
        AppLanguageService.instance.tr('emergency.unexpected_alert_error'),
      );
    } finally {
      if (mounted) {
        setState(() => _isSendingAlert = false);
      }
    }
  }

  Future<void> _callEmergencyContact(ContactModel contact) async {
    final result = await _alertService.callEmergencyContact(contact);
    if (mounted && result.message != null) {
      _showSnackBar(result.message!);
    }
  }

  Future<void> _rememberIncidentId(
    Future<EmergencyIncidentResult> incidentFuture,
  ) async {
    final result = await incidentFuture;
    if (_incidentCreationFuture != incidentFuture) return;

    if (result.success && result.incidentId != null) {
      _activeIncidentId = result.incidentId;
    }
  }

  Future<String?> _resolveIncidentId({
    String? locationUrl,
    Future<EmergencyIncidentResult>? pendingIncidentFuture,
    DateTime? alertTriggeredAt,
  }) async {
    if (_activeIncidentId != null && _activeIncidentId!.isNotEmpty) {
      return _activeIncidentId;
    }

    if (pendingIncidentFuture != null) {
      final result = await pendingIncidentFuture;
      if (result.success && result.incidentId != null) {
        _activeIncidentId = result.incidentId;
        return result.incidentId;
      }
    }

    final createResult = await _backendService.createIncident(
      locationUrl: locationUrl,
      alertTriggeredAt: alertTriggeredAt,
    );
    if (createResult.success && createResult.incidentId != null) {
      _activeIncidentId = createResult.incidentId;
      return createResult.incidentId;
    }

    if (mounted && createResult.message != null) {
      _showSnackBar(createResult.message!);
    }

    return null;
  }

  Future<List<ContactModel>> _loadEmergencyContacts() async {
    final user = await _authService.getSession();
    if (user == null) return [];
    return _contactsService.getContacts(user.id);
  }

  String _buildCaptureStatus(EmergencyCaptureResult capture) {
    final parts = <String>[];
    if (capture.videoStarted) parts.add('video');
    if (capture.audioStarted) parts.add('audio');
    if (capture.position != null) parts.add('ubicacion');

    if (parts.isEmpty) {
      return AppLanguageService.instance.tr(
        'emergency.capture_preparing_alert',
      );
    }

    return AppLanguageService.instance.tr(
      'emergency.capture_active',
      params: {'parts': parts.join(', ')},
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showAlertDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: AppFloatingSurface(
          borderRadius: 28,
          amplitude: 2.4,
          phase: math.pi / 4,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.cardBg.withValues(alpha: 0.98),
              AppTheme.primaryDark.withValues(alpha: 0.94),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.error.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.crisis_alert,
                      color: AppTheme.error,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      context.tr('emergency.dialog_title'),
                      style: AppTheme.titleLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                context.tr(
                  'emergency.dialog_body',
                  fallback:
                      'Se inicio la alerta de emergencia. Video, audio y ubicacion quedan activos mientras mantengas esta alerta. Al detenerla se preparara la evidencia para correo de emergencia o para compartirla.',
                ),
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textPrimary.withValues(alpha: 0.82),
                ),
              ),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _deactivateAlert();
                  },
                  child: Text(
                    context.tr('emergency.dialog_action'),
                    style: const TextStyle(color: AppTheme.success),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    unawaited(_captureService.stopEmergencyCapture());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: widget.isEmbedded
          ? AppBar(title: Text(context.tr('emergency.title_embedded')))
          : null,
      body: Stack(
        children: [
          const Positioned.fill(child: _EmergencyBackdrop()),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!widget.isEmbedded) ...[
                    _EmergencyHeroCard(
                      title: context.tr('emergency.title'),
                      subtitle: context.tr('emergency.subtitle'),
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (_isRecording || _isProcessingEvidence) ...[
                    AppFloatingSurface(
                      padding: const EdgeInsets.all(14),
                      borderRadius: 20,
                      amplitude: 2.6,
                      phase: math.pi / 2,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          (_isProcessingEvidence
                                  ? AppTheme.warning
                                  : AppTheme.error)
                              .withValues(alpha: 0.22),
                          AppTheme.cardBg.withValues(alpha: 0.90),
                        ],
                      ),
                      borderColor:
                          (_isProcessingEvidence
                                  ? AppTheme.warning
                                  : AppTheme.error)
                              .withValues(alpha: 0.55),
                      child: Row(
                        children: [
                          Icon(
                            _isProcessingEvidence
                                ? Icons.hourglass_top
                                : Icons.mic,
                            color: _isProcessingEvidence
                                ? AppTheme.warning
                                : AppTheme.error,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _isProcessingEvidence
                                  ? (_processingStatus ??
                                        context.tr(
                                          'emergency.processing_default',
                                        ))
                                  : _captureStatus,
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.textPrimary.withValues(
                                  alpha: 0.88,
                                ),
                              ),
                            ),
                          ),
                          if (_isProcessingEvidence)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.warning,
                              ),
                            )
                          else
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppTheme.error,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  AppFloatingSurface(
                    padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
                    borderRadius: 34,
                    amplitude: 4.1,
                    phase: math.pi / 6,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.cardBg.withValues(alpha: 0.98),
                        AppTheme.primaryDark.withValues(alpha: 0.94),
                      ],
                    ),
                    child: Column(
                      children: [
                        Center(child: PanicButton(onActivated: _activateAlert)),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: (_isRecording || _isProcessingEvidence)
                                ? null
                                : _activateAlert,
                            icon: Icon(
                              _isRecording
                                  ? Icons.shield_outlined
                                  : Icons.sos_rounded,
                            ),
                            label: Text(
                              _isRecording
                                  ? context.tr('emergency.active_button')
                                  : context.tr('emergency.activate_button'),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.error,
                              foregroundColor: AppTheme.textPrimary,
                              disabledBackgroundColor: AppTheme.error
                                  .withValues(alpha: 0.45),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  _FloatingSectionBadge(
                    icon: Icons.auto_awesome_rounded,
                    label: context.tr('emergency.quick_actions'),
                    phase: math.pi / 3,
                  ),
                  const SizedBox(height: 16),
                  _ActionCard(
                    icon: Icons.share_location_rounded,
                    iconColor: AppTheme.primaryLight,
                    title: context.tr('emergency.share_title'),
                    subtitle: context.tr(
                      'emergency.share_subtitle',
                      fallback:
                          'Incluye fecha y hora; usa WhatsApp, SMS o reintento al volver internet',
                    ),
                    floatPhase: 0.2,
                    onTap: () => _sendEmergencyAlert(
                      locationUrl: _activeLocationUrl,
                      alertTriggeredAt: _activeAlertTriggeredAt,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _ActionCard(
                    icon: Icons.mic_rounded,
                    iconColor: AppTheme.error,
                    title: context.tr('emergency.record_title'),
                    subtitle: context.tr('emergency.record_subtitle'),
                    floatPhase: 0.9,
                    onTap: _activateAlert,
                  ),
                  const SizedBox(height: 10),
                  _ActionCard(
                    icon: Icons.message_rounded,
                    iconColor: AppTheme.success,
                    title: context.tr('emergency.help_title'),
                    subtitle: context.tr(
                      'emergency.help_subtitle',
                      fallback:
                          'WhatsApp directo, SMS sin internet y reintento si vuelve la conexion',
                    ),
                    floatPhase: 1.5,
                    onTap: () => _sendEmergencyAlert(
                      locationUrl: _activeLocationUrl,
                      alertTriggeredAt: _activeAlertTriggeredAt,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _FloatingSectionBadge(
                    icon: Icons.favorite_outline_rounded,
                    label: context.tr('emergency.contacts_title'),
                    phase: math.pi / 1.8,
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<List<ContactModel>>(
                    future: _loadEmergencyContacts(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppTheme.primary,
                            ),
                          ),
                        );
                      }

                      final contacts = snapshot.data ?? const <ContactModel>[];

                      if (contacts.isEmpty) {
                        return _ActionCard(
                          icon: Icons.people_outline_rounded,
                          iconColor: AppTheme.warning,
                          title: context.tr('emergency.contacts_empty_title'),
                          subtitle: context.tr(
                            'emergency.contacts_empty_subtitle',
                          ),
                          floatPhase: 1.1,
                          onTap: () {
                            _showSnackBar(
                              context.tr('emergency.contacts_empty_snackbar'),
                            );
                          },
                        );
                      }

                      return Column(
                        children: [
                          for (var i = 0; i < contacts.length; i++) ...[
                            _ActionCard(
                              icon: Icons.phone_in_talk_rounded,
                              iconColor: AppTheme.warning,
                              title: context.tr(
                                'emergency.call_contact',
                                params: {'name': contacts[i].name},
                              ),
                              subtitle:
                                  '${contacts[i].relation} - ${contacts[i].phone}',
                              floatPhase: 1.2 + (i * 0.35),
                              onTap: () {
                                unawaited(_callEmergencyContact(contacts[i]));
                              },
                            ),
                            if (i != contacts.length - 1)
                              const SizedBox(height: 10),
                          ],
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          if (_isProcessingEvidence)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.42),
                child: Center(
                  child: SizedBox(
                    width: 280,
                    child: AppFloatingSurface(
                      borderRadius: 26,
                      amplitude: 2.2,
                      phase: math.pi / 5,
                      padding: const EdgeInsets.all(20),
                      backgroundColor: AppTheme.cardBg,
                      borderColor: AppTheme.divider.withValues(alpha: 0.85),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.cardBg.withValues(alpha: 0.98),
                          AppTheme.primaryDark.withValues(alpha: 0.92),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(
                            color: AppTheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _processingStatus ??
                                context.tr('emergency.processing_default'),
                            style: AppTheme.titleLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            context.tr('emergency.processing_wait'),
                            style: AppTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmergencyBackdrop extends StatelessWidget {
  const _EmergencyBackdrop();

  @override
  Widget build(BuildContext context) {
    final animation =
        AppDesignMotion.maybeOf(context) ??
        const AlwaysStoppedAnimation<double>(0);

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final progress = animation.value * math.pi * 2;

        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.surface,
                Color.lerp(AppTheme.surface, AppTheme.primaryDark, 0.45) ??
                    AppTheme.surface,
                Color.lerp(AppTheme.surface, AppTheme.cardBg, 0.55) ??
                    AppTheme.cardBg,
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -48 + (math.sin(progress) * 14),
                right: -36,
                child: _BackdropOrb(
                  size: 220,
                  color: AppTheme.primaryLight.withValues(alpha: 0.16),
                ),
              ),
              Positioned(
                top: 260 + (math.cos(progress + 0.9) * 18),
                left: -62,
                child: _BackdropOrb(
                  size: 180,
                  color: AppTheme.accent.withValues(alpha: 0.14),
                ),
              ),
              Positioned(
                bottom: -54 + (math.sin(progress + 1.4) * 16),
                right: 24,
                child: _BackdropOrb(
                  size: 210,
                  color: AppTheme.icedMint.withValues(alpha: 0.08),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BackdropOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _BackdropOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0.05), Colors.transparent],
          ),
        ),
      ),
    );
  }
}

class _EmergencyHeroCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _EmergencyHeroCard({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return AppFloatingSurface(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      borderRadius: 28,
      amplitude: 3.6,
      phase: 0.12,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppTheme.cardBg.withValues(alpha: 0.98),
          AppTheme.primaryDark.withValues(alpha: 0.94),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppTheme.icedMint.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppTheme.icedMint.withValues(alpha: 0.20),
              ),
            ),
            child: const Icon(
              Icons.shield_rounded,
              color: AppTheme.icedMint,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.headlineMedium),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textPrimary.withValues(alpha: 0.78),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingSectionBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final double phase;

  const _FloatingSectionBadge({
    required this.icon,
    required this.label,
    required this.phase,
  });

  @override
  Widget build(BuildContext context) {
    return AppFloatingSurface(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      borderRadius: 22,
      amplitude: 2.4,
      phase: phase,
      backgroundColor: AppTheme.cardBg.withValues(alpha: 0.86),
      borderColor: AppTheme.divider.withValues(alpha: 0.68),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: AppTheme.primaryLight),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: AppTheme.labelLarge.copyWith(
              fontSize: 13.5,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final double floatPhase;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.floatPhase = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      borderRadius: 20,
      floatPhase: floatPhase,
      floatAmplitude: 2.9,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppTheme.cardBg.withValues(alpha: 0.96),
          AppTheme.primaryDark.withValues(alpha: 0.88),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.labelLarge),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: AppTheme.bodyMedium.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: AppTheme.textSecondary,
          ),
        ],
      ),
    );
  }
}

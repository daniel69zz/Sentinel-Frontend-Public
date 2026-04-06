import 'package:flutter/material.dart';

import '../../../../core/localization/app_language_service.dart';
import '../../../../core/services/permissions_warmup_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/custom_card.dart';

class ProfilePermissionsScreen extends StatefulWidget {
  const ProfilePermissionsScreen({super.key});

  @override
  State<ProfilePermissionsScreen> createState() =>
      _ProfilePermissionsScreenState();
}

class _ProfilePermissionsScreenState extends State<ProfilePermissionsScreen> {
  PermissionsWarmupResult? _status;
  bool _isRequesting = false;

  @override
  void initState() {
    super.initState();
    _refreshStatus();
  }

  Future<void> _refreshStatus({bool forcePrompt = false}) async {
    setState(() => _isRequesting = true);
    final status = await PermissionsWarmupService.instance
        .requestCriticalPermissions(forcePrompt: forcePrompt);
    if (!mounted) return;
    setState(() {
      _status = status;
      _isRequesting = false;
    });

    if (!status.allGranted) {
      final missing = status.missing.join(', ');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr(
              'profile.permissions.missing',
              fallback:
                  'Faltan permisos ($missing). Ve a Ajustes si algun permiso quedo bloqueado.',
            ),
          ),
          action: SnackBarAction(
            label: context.tr(
              'profile.permissions.settings',
              fallback: 'Ajustes',
            ),
            textColor: AppTheme.surface,
            onPressed: () =>
                PermissionsWarmupService.instance.openSystemSettings(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _status;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: Text(
          context.tr('profile.permissions.title', fallback: 'Permisos clave'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr(
                  'profile.permissions.subtitle',
                  fallback:
                      'Activa camara, microfono, almacenamiento y ubicacion para que las alertas SOS y las evidencias funcionen sin bloqueos.',
                ),
                style: AppTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              CustomCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    _PermissionRow(
                      label: context.tr(
                        'profile.permissions.camera',
                        fallback: 'Camara',
                      ),
                      granted: status?.cameraGranted ?? false,
                    ),
                    const Divider(height: 20),
                  _PermissionRow(
                    label: context.tr(
                      'profile.permissions.microphone',
                      fallback: 'Microfono',
                    ),
                    granted: status?.microphoneGranted ?? false,
                  ),
                  const Divider(height: 20),
                  _PermissionRow(
                    label: context.tr(
                      'profile.permissions.storage',
                      fallback: 'Almacenamiento',
                    ),
                    granted: status?.storageGranted ?? false,
                  ),
                  const Divider(height: 20),
                  _PermissionRow(
                    label: context.tr(
                      'profile.permissions.location',
                      fallback: 'Ubicacion',
                    ),
                      granted:
                          (status?.locationGranted ?? false) &&
                          (status?.locationServiceEnabled ?? false),
                      helper: status != null && !status.locationServiceEnabled
                          ? context.tr(
                              'profile.permissions.location_disabled',
                              fallback: 'Activa la ubicacion del telefono.',
                            )
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isRequesting
                      ? null
                      : () => _refreshStatus(forcePrompt: true),
                  icon: _isRequesting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.verified_user_rounded),
                  label: Text(
                    context.tr(
                      'profile.permissions.request_now',
                      fallback: 'Solicitar permisos ahora',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () =>
                      PermissionsWarmupService.instance.openSystemSettings(),
                  icon: const Icon(Icons.settings_applications_outlined),
                  label: Text(
                    context.tr(
                      'profile.permissions.open_settings',
                      fallback: 'Abrir ajustes del sistema',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionRow extends StatelessWidget {
  final String label;
  final bool granted;
  final String? helper;

  const _PermissionRow({
    required this.label,
    required this.granted,
    this.helper,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          granted ? Icons.check_circle_rounded : Icons.error_outline_rounded,
          color: granted ? AppTheme.success : AppTheme.warning,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTheme.labelLarge),
              if (helper != null) ...[
                const SizedBox(height: 4),
                Text(helper!, style: AppTheme.bodyMedium),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

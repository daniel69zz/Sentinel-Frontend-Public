import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../auth/presentation/services/auth_service.dart';
import '../../../auth/presentation/services/contacts_service.dart';
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
  String _captureStatus = 'Grabando video, audio y ubicacion...';

  final AuthService _authService = AuthService();
  final ContactsService _contactsService = ContactsService();
  final EmergencyCaptureService _captureService = EmergencyCaptureService();

  Future<void> _activateAlert() async {
    if (_isRecording) return;

    final capture = await _captureService.startEmergencyCapture();
    if (!mounted) return;

    if (!capture.hasAnyAction) {
      for (final issue in capture.issues) {
        _showSnackBar(issue);
      }
      return;
    }

    setState(() {
      _isRecording = true;
      _captureStatus = _buildCaptureStatus(capture);
    });

    for (final issue in capture.issues) {
      _showSnackBar(issue);
    }

    unawaited(_sendEmergencyAlert(locationUrl: capture.mapsUrl));
    _showAlertDialog();
  }

  Future<void> _deactivateAlert() async {
    await _captureService.stopEmergencyCapture();
    if (!mounted) return;
    setState(() => _isRecording = false);
  }

  Future<void> _sendEmergencyAlert({String? locationUrl}) async {
    if (_isSendingAlert) return;

    setState(() => _isSendingAlert = true);

    try {
      final user = await _authService.getSession();
      if (user == null) {
        _showSnackBar('No hay una sesion activa.');
        return;
      }

      final contacts = await _contactsService.getContacts(user.id);
      final phones = contacts
          .map((contact) => _normalizePhone(contact.phone))
          .where((phone) => phone.isNotEmpty)
          .toSet()
          .toList();

      if (phones.isEmpty) {
        _showSnackBar('No tienes contactos de emergencia configurados.');
        return;
      }

      final smsUri = Uri(
        scheme: 'sms',
        path: phones.join(','),
        queryParameters: {
          'body': _buildEmergencyMessage(locationUrl),
        },
      );

      final opened = await launchUrl(
        smsUri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened) {
        _showSnackBar('No se pudo abrir la app de mensajes.');
        return;
      }

      final suffix = phones.length == 1
          ? '.'
          : ' para ${phones.length} contactos.';
      _showSnackBar('Se preparo la alerta con tu ubicacion$suffix');
    } catch (_) {
      _showSnackBar('Ocurrio un error al preparar la alerta.');
    } finally {
      if (mounted) {
        setState(() => _isSendingAlert = false);
      }
    }
  }

  Future<void> _callEmergencyContact(ContactModel contact) async {
    final phone = _normalizePhone(contact.phone);
    if (phone.isEmpty) {
      _showSnackBar('El contacto ${contact.name} no tiene un numero valido.');
      return;
    }

    final callUri = Uri(scheme: 'tel', path: phone);

    try {
      final opened = await launchUrl(
        callUri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened) {
        _showSnackBar('No se pudo iniciar la llamada a ${contact.name}.');
      }
    } catch (_) {
      _showSnackBar('Ocurrio un error al intentar llamar a ${contact.name}.');
    }
  }

  Future<List<ContactModel>> _loadEmergencyContacts() async {
    final user = await _authService.getSession();
    if (user == null) return [];
    return _contactsService.getContacts(user.id);
  }

  String _buildEmergencyMessage(String? locationUrl) {
    if (locationUrl == null) {
      return 'Hola, necesito ayuda ahora.';
    }

    return 'Hola, necesito ayuda ahora. Mi ubicacion es: $locationUrl';
  }

  String _buildCaptureStatus(EmergencyCaptureResult capture) {
    final parts = <String>[];
    if (capture.videoStarted) parts.add('video');
    if (capture.audioStarted) parts.add('audio');
    if (capture.position != null) parts.add('ubicacion');

    if (parts.isEmpty) {
      return 'Preparando alerta de emergencia...';
    }

    return 'Activa: ${parts.join(', ')}';
  }

  String _normalizePhone(String phone) {
    final trimmed = phone.trim();
    if (trimmed.isEmpty) return '';

    final hasLeadingPlus = trimmed.startsWith('+');
    var digits = trimmed.replaceAll(RegExp(r'\D'), '');

    if (digits.startsWith('00')) {
      digits = digits.substring(2);
      return digits.isEmpty ? '' : '+$digits';
    }

    if (hasLeadingPlus) {
      return digits.isEmpty ? '' : '+$digits';
    }

    if (digits.startsWith('591')) {
      return '+$digits';
    }

    return digits;
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showAlertDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.error.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.crisis_alert,
                color: AppTheme.error,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Alerta activada', style: AppTheme.titleLarge),
          ],
        ),
        content: Text(
          'Se inicio la alerta de emergencia. Video, audio y ubicacion quedan activos mientras mantengas esta alerta.',
          style: AppTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deactivateAlert();
            },
            child: const Text(
              'Estoy segura',
              style: TextStyle(color: AppTheme.success),
            ),
          ),
        ],
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
          ? AppBar(title: const Text('Alerta de Emergencia'))
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!widget.isEmbedded) ...[
                const SizedBox(height: 24),
                Text('Emergencia', style: AppTheme.headlineLarge),
                const SizedBox(height: 6),
                Text('Alerta rapida y segura', style: AppTheme.bodyMedium),
              ],
              const SizedBox(height: 32),
              if (_isRecording)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.error.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.mic, color: AppTheme.error, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _captureStatus,
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.error,
                          ),
                        ),
                      ),
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
              Center(child: PanicButton(onActivated: _activateAlert)),
              const SizedBox(height: 36),
              const Divider(color: AppTheme.divider),
              const SizedBox(height: 24),
              Text('Acciones rapidas', style: AppTheme.titleLarge),
              const SizedBox(height: 16),
              _ActionCard(
                icon: Icons.share_location_rounded,
                iconColor: const Color(0xFF2196F3),
                title: 'Compartir ubicacion',
                subtitle: 'Preparar SMS para todos tus contactos',
                onTap: () => _sendEmergencyAlert(),
              ),
              const SizedBox(height: 10),
              _ActionCard(
                icon: Icons.mic_rounded,
                iconColor: AppTheme.error,
                title: 'Grabar evidencia',
                subtitle: 'Se activa automaticamente con el boton SOS',
                onTap: _activateAlert,
              ),
              const SizedBox(height: 10),
              _ActionCard(
                icon: Icons.message_rounded,
                iconColor: AppTheme.success,
                title: 'Mensaje de auxilio',
                subtitle: 'Enviar alerta con ubicacion a varios contactos',
                onTap: () => _sendEmergencyAlert(),
              ),
              const SizedBox(height: 24),
              Text('Contactos de emergencia', style: AppTheme.titleLarge),
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
                      title: 'Sin contactos de emergencia',
                      subtitle:
                          'Agrega contactos en tu perfil para poder llamarlos desde aqui',
                      onTap: () {
                        _showSnackBar(
                          'No tienes contactos de emergencia configurados.',
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
                          title: 'Llamar a ${contacts[i].name}',
                          subtitle:
                              '${contacts[i].relation} • ${contacts[i].phone}',
                          onTap: () {
                            unawaited(_callEmergencyContact(contacts[i]));
                          },
                        ),
                        if (i != contacts.length - 1) const SizedBox(height: 10),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
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

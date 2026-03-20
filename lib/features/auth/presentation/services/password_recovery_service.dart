import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import 'auth_identity_mapper.dart';

class PasswordRecoveryResult {
  final bool success;
  final String message;
  final String? debugCode;

  const PasswordRecoveryResult({
    required this.success,
    required this.message,
    this.debugCode,
  });
}

class PasswordRecoveryService {
  static const _pendingRecoveryKey = 'sentinel_pending_password_recovery';
  static const _codeLifetime = Duration(minutes: 10);

  Future<PasswordRecoveryResult> sendVerificationCode(String email) async {
    final normalizedEmail = AuthIdentityMapper.normalizeEmail(email);
    if (!AuthIdentityMapper.isValidEmail(normalizedEmail)) {
      return const PasswordRecoveryResult(
        success: false,
        message: 'Ingresa un correo Gmail valido.',
      );
    }

    final code = _generateCode();
    final payload = {
      'email': normalizedEmail,
      'code': code,
      'expiresAt': DateTime.now().add(_codeLifetime).millisecondsSinceEpoch,
    };

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pendingRecoveryKey, jsonEncode(payload));

    return PasswordRecoveryResult(
      success: true,
      message: 'Te enviamos un codigo de verificacion a $normalizedEmail.',
      debugCode: code,
    );
  }

  Future<PasswordRecoveryResult> verifyCode({
    required String email,
    required String code,
  }) async {
    final normalizedEmail = AuthIdentityMapper.normalizeEmail(email);
    final normalizedCode = code.trim();

    if (!AuthIdentityMapper.isValidEmail(normalizedEmail)) {
      return const PasswordRecoveryResult(
        success: false,
        message: 'Ingresa un correo Gmail valido.',
      );
    }

    if (normalizedCode.length != 6) {
      return const PasswordRecoveryResult(
        success: false,
        message: 'Ingresa el codigo de 6 digitos.',
      );
    }

    final prefs = await SharedPreferences.getInstance();
    final rawPending = prefs.getString(_pendingRecoveryKey);
    if (rawPending == null || rawPending.trim().isEmpty) {
      return const PasswordRecoveryResult(
        success: false,
        message: 'Primero solicita un codigo de verificacion.',
      );
    }

    try {
      final payload = Map<String, dynamic>.from(jsonDecode(rawPending) as Map);
      final storedEmail = AuthIdentityMapper.normalizeEmail(
        payload['email']?.toString() ?? '',
      );
      final storedCode = payload['code']?.toString() ?? '';
      final expiresAt = int.tryParse(payload['expiresAt']?.toString() ?? '');

      if (storedEmail != normalizedEmail) {
        return const PasswordRecoveryResult(
          success: false,
          message: 'El codigo solicitado pertenece a otro correo.',
        );
      }

      if (expiresAt == null ||
          DateTime.now().millisecondsSinceEpoch > expiresAt) {
        await prefs.remove(_pendingRecoveryKey);
        return const PasswordRecoveryResult(
          success: false,
          message: 'El codigo ya vencio. Solicita uno nuevo.',
        );
      }

      if (storedCode != normalizedCode) {
        return const PasswordRecoveryResult(
          success: false,
          message: 'El codigo ingresado no coincide.',
        );
      }

      await prefs.remove(_pendingRecoveryKey);

      return const PasswordRecoveryResult(
        success: true,
        message:
            'Codigo verificado correctamente. El flujo ya queda listo para conectar el cambio real de contrasena.',
      );
    } catch (_) {
      await prefs.remove(_pendingRecoveryKey);
      return const PasswordRecoveryResult(
        success: false,
        message: 'No se pudo validar el codigo. Intenta nuevamente.',
      );
    }
  }

  String _generateCode() {
    final random = Random();
    final value = random.nextInt(900000) + 100000;
    return value.toString();
  }
}

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/localization/app_language_service.dart';
import '../../../../core/services/app_branding_service.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import 'account_email_registry.dart';
import 'auth_identity_mapper.dart';

class UserModel {
  final String id;
  final String profileId;
  final String name;
  final String phone;
  final String city;
  final String? birthDate;
  final String email;
  final String accessToken;
  final String refreshToken;
  final String createdAt;

  const UserModel({
    required this.id,
    required this.profileId,
    required this.name,
    required this.phone,
    required this.city,
    this.birthDate,
    required this.email,
    required this.accessToken,
    required this.refreshToken,
    required this.createdAt,
  });

  bool get hasRemoteSession => accessToken.trim().isNotEmpty;

  Map<String, dynamic> toJson() => {
    'id': id,
    'profileId': profileId,
    'name': name,
    'phone': phone,
    'city': city,
    'birthDate': birthDate,
    'email': email,
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'createdAt': createdAt,
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: _readString(json['id']),
    profileId: _readString(json['profileId'] ?? json['profile_id']),
    name: _readString(json['name'], fallback: 'Usuaria'),
    phone: _readString(json['phone']),
    city: _readString(json['city'], fallback: 'Bolivia'),
    birthDate: _readNullableString(
      json['birthDate'] ?? json['fecha_nacimiento'],
    ),
    email: _readString(
      json['email'],
      fallback: AuthIdentityMapper.buildEmailFromPhone(
        _readString(json['phone']),
      ),
    ),
    accessToken: _readString(json['accessToken'] ?? json['access_token']),
    refreshToken: _readString(json['refreshToken'] ?? json['refresh_token']),
    createdAt: _readString(
      json['createdAt'] ?? json['created_at'],
      fallback: DateTime.now().toIso8601String(),
    ),
  );
}

class AuthResult {
  final bool success;
  final String message;
  final UserModel? user;

  const AuthResult({required this.success, required this.message, this.user});
}

class AuthService {
  static const _sessionKey = 'sentinel_session';

  final ApiClient _apiClient;
  final AccountEmailRegistry _emailRegistry;

  AuthService({ApiClient? apiClient, AccountEmailRegistry? emailRegistry})
    : _apiClient = apiClient ?? ApiClient(),
      _emailRegistry = emailRegistry ?? AccountEmailRegistry();

  Future<void> _saveSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, jsonEncode(user.toJson()));
    await _emailRegistry.remember(user.email);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  Future<UserModel?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_sessionKey);
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }

    try {
      final user = UserModel.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
      if (!user.hasRemoteSession) {
        await prefs.remove(_sessionKey);
        return null;
      }
      await _emailRegistry.remember(user.email);
      return user;
    } catch (_) {
      await prefs.remove(_sessionKey);
      return null;
    }
  }

  Future<AuthResult> login(String email, String password) async {
    final t = AppLanguageService.instance;
    final normalizedEmail = AuthIdentityMapper.normalizeEmail(email);
    if (!AuthIdentityMapper.isValidEmail(normalizedEmail)) {
      return AuthResult(
        success: false,
        message: t.tr(
          'auth.service.invalid_email',
          fallback: 'Ingresa un correo Gmail valido.',
        ),
      );
    }

    try {
      final response = await _apiClient.postJson(
        '/auth/login',
        body: {'email': normalizedEmail, 'password': password},
      );

      final data = _extractDataMap(response);
      final authUser = _extractChildMap(data, 'user');
      final session = _extractChildMap(data, 'session');
      final accessToken = _readString(session['access_token']);

      if (authUser.isEmpty || accessToken.isEmpty) {
        return AuthResult(
          success: false,
          message: t.tr(
            'auth.service.invalid_session',
            fallback: 'La cuenta no devolvio una sesion valida.',
          ),
        );
      }

      final profile = await _fetchProfile(accessToken);
      final user = _buildUserModel(
        authUser: authUser,
        profile: profile,
        session: session,
        fallbackPhone: '',
      );

      await _saveSession(user);

      return AuthResult(
        success: true,
        message: t.tr(
          'auth.service.welcome',
          params: {'name': user.name.split(' ').first},
          fallback: 'Bienvenida, ${user.name.split(' ').first}',
        ),
        user: user,
      );
    } on ApiException catch (error) {
      return AuthResult(success: false, message: _mapErrorMessage(error));
    } catch (_) {
      return AuthResult(
        success: false,
        message: t.tr(
          'auth.service.login_error',
          fallback: 'Error al iniciar sesion.',
        ),
      );
    }
  }

  Future<AuthResult> register(
    String firstNames,
    String lastNames,
    String email,
    String phone,
    String password,
    String city,
    DateTime birthDate,
  ) async {
    final t = AppLanguageService.instance;
    final normalizedFirstNames = firstNames
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .join(' ');
    if (normalizedFirstNames.isEmpty) {
      return AuthResult(
        success: false,
        message: t.tr(
          'auth.service.first_names_required',
          fallback: 'Ingresa tus nombres.',
        ),
      );
    }

    final normalizedLastNames = lastNames
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .join(' ');
    if (normalizedLastNames.isEmpty) {
      return AuthResult(
        success: false,
        message: t.tr(
          'auth.service.last_names_required',
          fallback: 'Ingresa tus apellidos.',
        ),
      );
    }

    final normalizedEmail = AuthIdentityMapper.normalizeEmail(email);
    if (!AuthIdentityMapper.isValidEmail(normalizedEmail)) {
      return AuthResult(
        success: false,
        message: t.tr(
          'auth.service.invalid_email',
          fallback: 'Ingresa un correo Gmail valido.',
        ),
      );
    }

    if (await _emailRegistry.isKnown(normalizedEmail)) {
      return AuthResult(
        success: false,
        message: t.tr(
          'auth.service.duplicate_email',
          fallback: 'Ya existe una cuenta con ese correo Gmail.',
        ),
      );
    }

    final normalizedPhone = AuthIdentityMapper.normalizePhone(phone);
    if (normalizedPhone.isEmpty) {
      return AuthResult(
        success: false,
        message: t.tr(
          'auth.service.invalid_phone',
          fallback: 'Ingresa un numero valido.',
        ),
      );
    }

    final nameParts = AuthIdentityMapper.buildNameParts(
      firstNames: normalizedFirstNames,
      lastNames: normalizedLastNames,
    );

    try {
      final registerResponse = await _apiClient.postJson(
        '/auth/register',
        body: {'email': normalizedEmail, 'password': password},
      );

      final data = _extractDataMap(registerResponse);
      final authUser = _extractChildMap(data, 'user');
      final session = _extractChildMap(data, 'session');
      final accessToken = _readString(session['access_token']);

      if (authUser.isEmpty || accessToken.isEmpty) {
        return AuthResult(
          success: false,
          message: t.tr(
            'auth.service.created_without_session',
            fallback:
                'La cuenta fue creada, pero el servidor no entrego una sesion activa.',
          ),
        );
      }

      Map<String, dynamic> profile;
      try {
        final profileResponse = await _apiClient.postJson(
          '/profiles',
          accessToken: accessToken,
          body: {
            'nombre': nameParts.firstName,
            'apellido_p': nameParts.lastName,
            'apellido_m': nameParts.middleLastName,
            'telefono': normalizedPhone,
            'email': normalizedEmail,
            'fecha_nacimiento': AuthIdentityMapper.formatBirthDate(birthDate),
            'direccion_opcional': AuthIdentityMapper.buildAddressFromCity(city),
          },
        );
        profile = _extractDataMap(profileResponse);
      } on ApiException catch (error) {
        if (error.statusCode == 409) {
          profile = await _fetchProfile(accessToken);
        } else {
          rethrow;
        }
      }

      final user = _buildUserModel(
        authUser: authUser,
        profile: profile,
        session: session,
        fallbackPhone: normalizedPhone,
      );

      await _saveSession(user);

      return AuthResult(
        success: true,
        message: t.tr(
          'auth.service.register_success',
          fallback: 'Cuenta creada exitosamente.',
        ),
        user: user,
      );
    } on ApiException catch (error) {
      return AuthResult(success: false, message: _mapErrorMessage(error));
    } catch (_) {
      return AuthResult(
        success: false,
        message: t.tr(
          'auth.service.register_error',
          fallback: 'Error al crear la cuenta.',
        ),
      );
    }
  }

  Future<Map<String, dynamic>> _fetchProfile(String accessToken) async {
    final response = await _apiClient.getJson(
      '/profiles/me',
      accessToken: accessToken,
    );
    return _extractDataMap(response);
  }

  UserModel _buildUserModel({
    required Map<String, dynamic> authUser,
    required Map<String, dynamic> profile,
    required Map<String, dynamic> session,
    required String fallbackPhone,
  }) {
    final firstName = _readString(profile['nombre']);
    final lastName = _readString(profile['apellido_p']);
    final middleLastName = _readString(profile['apellido_m']);
    final fullName = [
      firstName,
      lastName,
      middleLastName,
    ].where((part) => part.trim().isNotEmpty).join(' ');

    final phone = _readString(profile['telefono'], fallback: fallbackPhone);
    final city = AuthIdentityMapper.extractCity(
      _readNullableString(profile['direccion_opcional']),
    );
    final birthDate = _readNullableString(profile['fecha_nacimiento']);

    return UserModel(
      id: _readString(authUser['id']),
      profileId: _readString(profile['id']),
      name: fullName.isEmpty
          ? 'Usuaria ${AppBrandingService.instance.displayName}'
          : fullName,
      phone: phone,
      city: city,
      birthDate: birthDate,
      email: _readString(
        profile['email'],
        fallback: _readString(authUser['email']),
      ),
      accessToken: _readString(session['access_token']),
      refreshToken: _readString(session['refresh_token']),
      createdAt: _readString(
        profile['created_at'],
        fallback: DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> _extractDataMap(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    return <String, dynamic>{};
  }

  Map<String, dynamic> _extractChildMap(
    Map<String, dynamic> parent,
    String key,
  ) {
    final value = parent[key];
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return <String, dynamic>{};
  }

  String _mapErrorMessage(ApiException error) {
    final t = AppLanguageService.instance;
    final lowerMessage = error.message.toLowerCase();

    if (lowerMessage.contains('invalid login credentials') ||
        lowerMessage.contains('credenciales invalidas')) {
      return t.tr(
        'auth.service.invalid_credentials',
        fallback: 'Correo Gmail o contrasena incorrectos.',
      );
    }

    if (lowerMessage.contains('user already registered') ||
        lowerMessage.contains('already registered')) {
      return t.tr(
        'auth.service.duplicate_email',
        fallback: 'Ya existe una cuenta con ese correo Gmail.',
      );
    }

    if (lowerMessage.contains('email not confirmed')) {
      return t.tr(
        'auth.service.email_not_confirmed',
        fallback: 'Tu cuenta existe, pero necesita confirmacion antes de ingresar.',
      );
    }

    if (lowerMessage.contains('password') &&
        lowerMessage.contains('at least 8')) {
      return t.tr(
        'auth.service.password_min',
        fallback: 'La contrasena debe tener al menos 8 caracteres.',
      );
    }

    if (lowerMessage.contains('perfil no encontrado')) {
      return t.tr(
        'auth.service.profile_missing',
        fallback: 'La cuenta existe, pero todavia no tiene perfil configurado.',
      );
    }

    if (lowerMessage.contains('no se pudo conectar con el servidor')) {
      return t.tr(
        'auth.service.server_unavailable',
        params: {'appName': AppBrandingService.instance.displayName},
        fallback:
            'No se pudo conectar con el servidor ${AppBrandingService.instance.displayName}.',
      );
    }

    return error.message;
  }
}

String _readString(dynamic value, {String fallback = ''}) {
  if (value is String) {
    return value;
  }
  if (value == null) {
    return fallback;
  }
  return value.toString();
}

String? _readNullableString(dynamic value) {
  final stringValue = _readString(value);
  return stringValue.trim().isEmpty ? null : stringValue;
}

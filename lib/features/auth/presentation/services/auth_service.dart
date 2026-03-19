import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserModel {
  final String id;
  final String name;
  final String phone;
  final String password;
  final String city;
  final String createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.password,
    required this.city,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'password': password,
    'city': city,
    'createdAt': createdAt,
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'],
    name: json['name'],
    phone: json['phone'],
    password: json['password'],
    city: json['city'],
    createdAt: json['createdAt'],
  );
}

class AuthResult {
  final bool success;
  final String message;
  final UserModel? user;

  AuthResult({required this.success, required this.message, this.user});
}

// ----------------------------------------------------------------
// AuthService — usa SharedPreferences para guardar usuarios
// Cuando tengas backend: solo cambia login() y register()
// ----------------------------------------------------------------
class AuthService {
  static const _usersKey = 'sentinel_users';
  static const _sessionKey = 'sentinel_session';

  // Carga todos los usuarios guardados
  Future<List<UserModel>> _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_usersKey);
    if (raw == null) return [];
    final List decoded = json.decode(raw);
    return decoded.map((u) => UserModel.fromJson(u)).toList();
  }

  // Guarda la lista de usuarios
  Future<void> _saveUsers(List<UserModel> users) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(users.map((u) => u.toJson()).toList());
    await prefs.setString(_usersKey, encoded);
  }

  // Guarda la sesión activa
  Future<void> _saveSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, json.encode(user.toJson()));
  }

  // Cierra sesión
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  // Retorna el usuario logueado actualmente (o null)
  Future<UserModel?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_sessionKey);
    if (raw == null) return null;
    return UserModel.fromJson(json.decode(raw));
  }

  // LOGIN
  Future<AuthResult> login(String phone, String password) async {
    try {
      final users = await _loadUsers();

      final matches = users.where((u) => u.phone == phone).toList();
      if (matches.isEmpty) {
        return AuthResult(
          success: false,
          message: 'No existe una cuenta con ese número',
        );
      }

      final user = matches.first;
      if (user.password != password) {
        return AuthResult(success: false, message: 'Contraseña incorrecta');
      }

      await _saveSession(user);
      return AuthResult(
        success: true,
        message: 'Bienvenida, ${user.name}',
        user: user,
      );
    } catch (e) {
      return AuthResult(success: false, message: 'Error al iniciar sesión');
    }
  }

  // REGISTER
  Future<AuthResult> register(
    String name,
    String phone,
    String password,
    String city,
  ) async {
    try {
      final users = await _loadUsers();

      final exists = users.any((u) => u.phone == phone);
      if (exists) {
        return AuthResult(
          success: false,
          message: 'Ya existe una cuenta con ese número',
        );
      }

      final newUser = UserModel(
        id: 'u${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        phone: phone,
        password: password,
        city: city,
        createdAt: DateTime.now().toIso8601String().split('T')[0],
      );

      users.add(newUser);
      await _saveUsers(users);
      await _saveSession(newUser);

      return AuthResult(
        success: true,
        message: 'Cuenta creada exitosamente',
        user: newUser,
      );
    } catch (e) {
      return AuthResult(success: false, message: 'Error al crear la cuenta');
    }
  }
}

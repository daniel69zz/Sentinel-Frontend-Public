import 'package:flutter/material.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart'; // ← 1. import
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/emergency/presentation/screens/emergency_screen.dart';
import '../../features/education/presentation/screens/education_screen.dart';
import '../../features/directory/presentation/screens/directory_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register'; // ← 2. constante
  static const String home = '/home';
  static const String emergency = '/emergency';
  static const String education = '/education';
  static const String directory = '/directory';
  static const String profile = '/profile';

  static Map<String, WidgetBuilder> get routes => {
    login: (_) => const LoginScreen(),
    register: (_) => const RegisterScreen(), // ← 3. ruta
    home: (_) => const HomeScreen(),
    emergency: (_) => const EmergencyScreen(),
    education: (_) => const EducationScreen(),
    directory: (_) => const DirectoryScreen(),
    profile: (_) => const ProfileScreen(),
  };

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final builder = routes[settings.name];
    if (builder != null) {
      return MaterialPageRoute(builder: builder, settings: settings);
    }
    return MaterialPageRoute(
      builder: (_) =>
          const Scaffold(body: Center(child: Text('Página no encontrada'))),
    );
  }
}

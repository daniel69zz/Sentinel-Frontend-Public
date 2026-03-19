import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/bottom_nav.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../auth/presentation/services/auth_service.dart';
import '../../../emergency/presentation/screens/emergency_screen.dart';
import '../../../education/presentation/screens/education_screen.dart';
import '../../../directory/presentation/screens/directory_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _navigateTo(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      _HomeBody(onNavigate: _navigateTo),
      const EmergencyScreen(isEmbedded: true),
      const EducationScreen(isEmbedded: true),
      const DirectoryScreen(isEmbedded: true),
      const ProfileScreen(isEmbedded: true),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: _navigateTo,
      ),
    );
  }
}

// ── Home Body ─────────────────────────────────────────────────────
class _HomeBody extends StatefulWidget {
  final Function(int) onNavigate;

  const _HomeBody({required this.onNavigate});

  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody> {
  String _userName = 'Bienvenida';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await AuthService().getSession();
    if (user != null && mounted) {
      setState(() => _userName = user.name.split(' ').first);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hola, 👋', style: AppTheme.bodyMedium),
                      const SizedBox(height: 2),
                      Text(_userName, style: AppTheme.headlineMedium),
                    ],
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.notifications_outlined,
                      color: AppTheme.primary,
                      size: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Emergency Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '¿Estás en peligro?',
                            style: AppTheme.titleLarge.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Activa la alerta de emergencia inmediatamente',
                            style: AppTheme.bodyMedium.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => widget.onNavigate(1),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppTheme.primary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'ACTIVAR ALERTA',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.crisis_alert,
                      color: Colors.white30,
                      size: 64,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              Text('Acceso rápido', style: AppTheme.titleLarge),
              const SizedBox(height: 16),

              // Quick Access Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.1,
                children: [
                  _QuickAccessCard(
                    icon: Icons.menu_book_rounded,
                    label: 'Educación\nDSDR',
                    color: const Color(0xFF6C63FF),
                    onTap: () => widget.onNavigate(2),
                  ),
                  _QuickAccessCard(
                    icon: Icons.location_on_rounded,
                    label: 'Centros de\nApoyo',
                    color: const Color(0xFF00BCD4),
                    onTap: () => widget.onNavigate(3),
                  ),
                  _QuickAccessCard(
                    icon: Icons.people_rounded,
                    label: 'Contactos\nEmergencia',
                    color: const Color(0xFF4CAF50),
                    onTap: () => widget.onNavigate(4),
                  ),
                  _QuickAccessCard(
                    icon: Icons.health_and_safety_rounded,
                    label: 'Rutas de\nAtención',
                    color: const Color(0xFFF57C00),
                    onTap: () => widget.onNavigate(3),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              Text('Información importante', style: AppTheme.titleLarge),
              const SizedBox(height: 16),

              _InfoCard(
                icon: Icons.phone_rounded,
                iconColor: AppTheme.success,
                title: 'Línea de violencia Bolivia',
                subtitle: 'Llamada gratuita 24/7',
                trailing: '800-10-0200',
              ),
              const SizedBox(height: 10),
              _InfoCard(
                icon: Icons.local_hospital_rounded,
                iconColor: AppTheme.error,
                title: 'Emergencias',
                subtitle: 'Ambulancia y emergencias',
                trailing: '118',
              ),
              const SizedBox(height: 10),
              _InfoCard(
                icon: Icons.local_police_rounded,
                iconColor: const Color(0xFF2196F3),
                title: 'Policía Nacional',
                subtitle: 'Atención inmediata',
                trailing: '110',
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Quick Access Card ─────────────────────────────────────────────
class _QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAccessCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          Text(
            label,
            style: AppTheme.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Info Card ─────────────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String trailing;

  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              trailing,
              style: TextStyle(
                color: iconColor,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../auth/presentation/services/auth_service.dart';
import '../../../auth/presentation/services/contacts_service.dart';
import '../../../auth/presentation/screens/contacts_screen.dart';

class ProfileScreen extends StatefulWidget {
  final bool isEmbedded;

  const ProfileScreen({super.key, this.isEmbedded = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ContactsService _contactsService = ContactsService();
  final AuthService _authService = AuthService();

  UserModel? _user;
  List<ContactModel> _contacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final user = await _authService.getSession();
    if (user == null) return;
    final contacts = await _contactsService.getContacts(user.id);
    setState(() {
      _user = user;
      _contacts = contacts;
      _isLoading = false;
    });
  }

  void _goToContacts() async {
    if (_user == null) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ContactsScreen(userId: _user!.id)),
    );
    _loadData();
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: widget.isEmbedded
          ? AppBar(
              title: const Text('Mi Perfil'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () {},
                ),
              ],
            )
          : null,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    if (!widget.isEmbedded) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Perfil', style: AppTheme.headlineLarge),
                          IconButton(
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: AppTheme.primary,
                            ),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Avatar & Name
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppTheme.primary,
                                  AppTheme.primaryLight,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary.withOpacity(0.35),
                                  blurRadius: 20,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            _user?.name ?? 'Usuaria',
                            style: AppTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _user?.city ?? 'Bolivia',
                            style: AppTheme.bodyMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _user?.phone ?? '',
                            style: AppTheme.bodyMedium.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Contactos de emergencia
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Flexible(
                          child: Text(
                            'Contactos de emergencia',
                            style: AppTheme.titleLarge,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _goToContacts,
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Gestionar'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    _contacts.isEmpty
                        ? _EmptyContactsBanner(onTap: _goToContacts)
                        : Column(
                            children: _contacts.map((c) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: CustomCard(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: AppTheme.primary.withOpacity(
                                            0.15,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.person_outline,
                                          color: AppTheme.primary,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              c.name,
                                              style: AppTheme.labelLarge,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              c.relation,
                                              style: AppTheme.bodyMedium
                                                  .copyWith(
                                                    fontSize: 11,
                                                    color: AppTheme.primary,
                                                  ),
                                            ),
                                            const SizedBox(height: 1),
                                            Text(
                                              c.phone,
                                              style: AppTheme.bodyMedium
                                                  .copyWith(fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: AppTheme.error,
                                          size: 18,
                                        ),
                                        onPressed: () async {
                                          await _contactsService.deleteContact(
                                            _user!.id,
                                            c.id,
                                          );
                                          _loadData();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                    const SizedBox(height: 24),
                    Text('Configuración', style: AppTheme.titleLarge),
                    const SizedBox(height: 12),

                    _SettingTile(
                      icon: Icons.notifications_outlined,
                      title: 'Notificaciones',
                      subtitle: 'Alertas y avisos',
                      onTap: () {},
                    ),
                    _SettingTile(
                      icon: Icons.lock_outline,
                      title: 'Privacidad',
                      subtitle: 'Datos y permisos',
                      onTap: () {},
                    ),
                    _SettingTile(
                      icon: Icons.language_outlined,
                      title: 'Idioma',
                      subtitle: 'Español (Bolivia)',
                      onTap: () {},
                    ),
                    _SettingTile(
                      icon: Icons.info_outline,
                      title: 'Acerca de Sentinel',
                      subtitle: 'Versión 1.0.0',
                      onTap: () {},
                    ),
                    const SizedBox(height: 20),

                    // Logout
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _logout,
                        icon: const Icon(Icons.logout, size: 18),
                        label: const Text('Cerrar sesión'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.error,
                          side: const BorderSide(color: AppTheme.error),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }
}

// ── Banner cuando no hay contactos ────────────────────────────────
class _EmptyContactsBanner extends StatelessWidget {
  final VoidCallback onTap;

  const _EmptyContactsBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppTheme.primary.withOpacity(0.25),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.people_outline, color: AppTheme.primary, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sin contactos de emergencia',
                    style: AppTheme.labelLarge,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Toca aquí para agregar uno',
                    style: AppTheme.bodyMedium.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppTheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Setting tile ──────────────────────────────────────────────────
class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingTile({
    required this.icon,
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
          Icon(icon, color: AppTheme.textSecondary, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.labelLarge),
                const SizedBox(height: 2),
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

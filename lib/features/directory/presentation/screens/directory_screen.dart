import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/custom_card.dart';

class DirectoryScreen extends StatefulWidget {
  final bool isEmbedded;

  const DirectoryScreen({super.key, this.isEmbedded = false});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  int _selectedCategory = 0;

  final List<String> _categories = [
    'Todos',
    'Salud',
    'Legal',
    'Psicológico',
    'Albergues',
  ];

  final List<_Center> _centers = const [
    _Center(
      name: 'SLIM La Paz',
      type: 'Legal / Psicológico',
      address: 'Av. Arce #2333, La Paz',
      phone: '+591 2-2441230',
      icon: Icons.balance_rounded,
      color: Color(0xFF6C63FF),
      distance: '0.8 km',
      isOpen: true,
    ),
    _Center(
      name: 'Hospital de la Mujer',
      type: 'Salud',
      address: 'Av. Busch #1198, La Paz',
      phone: '+591 2-2242512',
      icon: Icons.local_hospital_rounded,
      color: Color(0xFFF44336),
      distance: '1.3 km',
      isOpen: true,
    ),
    _Center(
      name: 'CIDEM',
      type: 'Legal / Apoyo',
      address: 'Calle Landaeta #564, La Paz',
      phone: '+591 2-2490690',
      icon: Icons.people_rounded,
      color: Color(0xFF4CAF50),
      distance: '2.1 km',
      isOpen: false,
    ),
    _Center(
      name: 'Fiscalía FELCV',
      type: 'Legal',
      address: 'Av. Mariscal Santa Cruz, La Paz',
      phone: '+591 2-2202020',
      icon: Icons.gavel_rounded,
      color: Color(0xFFF57C00),
      distance: '2.4 km',
      isOpen: true,
    ),
    _Center(
      name: 'Línea 156 Bolivia',
      type: 'Psicológico',
      address: 'Atención telefónica nacional',
      phone: '156',
      icon: Icons.phone_in_talk_rounded,
      color: Color(0xFF00BCD4),
      distance: 'Nacional',
      isOpen: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: widget.isEmbedded
          ? AppBar(title: const Text('Directorio de Apoyo'))
          : null,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!widget.isEmbedded) ...[
                    Text('Directorio', style: AppTheme.headlineLarge),
                    const SizedBox(height: 6),
                    Text('Centros de apoyo cercanos', style: AppTheme.bodyMedium),
                    const SizedBox(height: 20),
                  ],
                  // Location banner
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2196F3).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: const Color(0xFF2196F3).withOpacity(0.25)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.my_location_rounded,
                            color: Color(0xFF2196F3), size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'La Paz, Bolivia · Actualizando...',
                          style: AppTheme.bodyMedium.copyWith(
                            color: const Color(0xFF2196F3),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Category chips
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final selected = _selectedCategory == i;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedCategory = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppTheme.primary
                                  : AppTheme.cardBg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: selected
                                    ? AppTheme.primary
                                    : AppTheme.divider,
                              ),
                            ),
                            child: Text(
                              _categories[i],
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? Colors.white
                                    : AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '${_centers.length} centros encontrados',
                    style: AppTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                itemCount: _centers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _CenterCard(center: _centers[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterCard extends StatelessWidget {
  final _Center center;

  const _CenterCard({required this.center});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: () {},
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: center.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(center.icon, color: center.color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(center.name, style: AppTheme.labelLarge),
                    const SizedBox(height: 3),
                    Text(
                      center.type,
                      style: AppTheme.bodyMedium.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (center.isOpen
                          ? AppTheme.success
                          : AppTheme.textSecondary)
                      .withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  center.isOpen ? 'Abierto' : 'Cerrado',
                  style: TextStyle(
                    color: center.isOpen
                        ? AppTheme.success
                        : AppTheme.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppTheme.divider, height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  color: AppTheme.textSecondary, size: 15),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  center.address,
                  style: AppTheme.bodyMedium.copyWith(fontSize: 12),
                ),
              ),
              Text(
                center.distance,
                style: AppTheme.bodyMedium.copyWith(
                    fontSize: 12, color: AppTheme.primaryLight),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.phone_outlined,
                  color: AppTheme.textSecondary, size: 15),
              const SizedBox(width: 6),
              Text(
                center.phone,
                style: AppTheme.bodyMedium.copyWith(fontSize: 12),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'Llamar',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Center {
  final String name;
  final String type;
  final String address;
  final String phone;
  final IconData icon;
  final Color color;
  final String distance;
  final bool isOpen;

  const _Center({
    required this.name,
    required this.type,
    required this.address,
    required this.phone,
    required this.icon,
    required this.color,
    required this.distance,
    required this.isOpen,
  });
}

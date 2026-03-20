import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/custom_card.dart';

class ProfileAboutScreen extends StatefulWidget {
  const ProfileAboutScreen({super.key});

  @override
  State<ProfileAboutScreen> createState() => _ProfileAboutScreenState();
}

class _ProfileAboutScreenState extends State<ProfileAboutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(title: const Text('Acerca de la app')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Que es esta app', style: AppTheme.titleLarge),
              const SizedBox(height: 12),
              CustomCard(
                child: Text(
                  'Es una app pensada para centralizar ayuda rapida, contactos de confianza y un acceso mas discreto segun la apariencia que elijas.',
                  style: AppTheme.bodyLarge,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

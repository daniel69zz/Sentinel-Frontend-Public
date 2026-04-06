import 'package:flutter/material.dart';

import '../../../../core/localization/app_language_service.dart';
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
      appBar: AppBar(title: Text(context.tr('profile.about_screen_title'))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.tr('profile.about_heading'), style: AppTheme.titleLarge),
              const SizedBox(height: 12),
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('profile.about_body'),
                      style: AppTheme.bodyLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      context.tr(
                        'profile.about_extra',
                        fallback:
                            'Sentinel integra alertas SOS con video/ubicacion, biblioteca de evidencias oculta, directorio de centros de ayuda y un chatbot de contencion. Puedes registrar un contacto prioritario y compartir evidencias aun sin internet cuando vuelva la conexion.',
                      ),
                      style: AppTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

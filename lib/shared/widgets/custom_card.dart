import 'package:flutter/material.dart';

import '../../core/theme/app_design_theme.dart';
import '../../core/theme/app_theme.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final bool hasShadow;
  final double floatPhase;
  final double floatAmplitude;
  final Gradient? gradient;

  const CustomCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = 16,
    this.hasShadow = false,
    this.floatPhase = 0,
    this.floatAmplitude = 3.2,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return AppFloatingSurface(
      onTap: onTap,
      padding: padding ?? const EdgeInsets.all(16),
      backgroundColor: backgroundColor ?? AppTheme.cardBg,
      borderColor: borderColor ?? AppTheme.divider,
      gradient: gradient,
      borderRadius: borderRadius,
      amplitude: floatAmplitude,
      phase: floatPhase,
      showShadow: true,
      child: child,
    );
  }
}

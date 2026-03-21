import 'package:flutter/material.dart';

class AppDesignMotion extends StatefulWidget {
  final Widget child;

  const AppDesignMotion({super.key, required this.child});

  static Animation<double>? maybeOf(BuildContext context) => null;

  @override
  State<AppDesignMotion> createState() => _AppDesignMotionState();
}

class _AppDesignMotionState extends State<AppDesignMotion> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class AppDesignTheme {
  static ButtonStyle elevatedButtonStyle({
    required Color fillColor,
    required Color foregroundColor,
    required Color shadowColor,
  }) {
    return _buttonStyle(
      fillColor: fillColor,
      foregroundColor: foregroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    );
  }

  static ButtonStyle filledButtonStyle({
    required Color fillColor,
    required Color foregroundColor,
    required Color shadowColor,
  }) {
    return _buttonStyle(
      fillColor: fillColor,
      foregroundColor: foregroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    );
  }

  static ButtonStyle outlinedButtonStyle({
    required Color fillColor,
    required Color foregroundColor,
    required Color borderColor,
    required Color shadowColor,
  }) {
    return _buttonStyle(
      fillColor: fillColor,
      foregroundColor: foregroundColor,
      fillOpacity: 0.18,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      side: BorderSide(color: borderColor, width: 1.15),
    );
  }

  static ButtonStyle textButtonStyle({
    required Color fillColor,
    required Color foregroundColor,
    required Color shadowColor,
  }) {
    return _buttonStyle(
      fillColor: fillColor,
      foregroundColor: foregroundColor,
      fillOpacity: 0.16,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      minimumSize: const Size(0, 48),
      shape: const StadiumBorder(),
    );
  }

  static ButtonStyle iconButtonStyle({
    required Color fillColor,
    required Color foregroundColor,
    required Color borderColor,
    required Color shadowColor,
  }) {
    return _buttonStyle(
      fillColor: fillColor,
      foregroundColor: foregroundColor,
      fillOpacity: 0.88,
      padding: const EdgeInsets.all(12),
      minimumSize: const Size(48, 48),
      shape: const CircleBorder(),
      side: BorderSide(color: borderColor, width: 1),
      iconSize: 21,
    );
  }

  static ButtonStyle _buttonStyle({
    required Color fillColor,
    required Color foregroundColor,
    required OutlinedBorder shape,
    BorderSide? side,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(
      horizontal: 22,
      vertical: 16,
    ),
    Size minimumSize = const Size(0, 58),
    double fillOpacity = 1,
    double iconSize = 20,
  }) {
    return ButtonStyle(
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return foregroundColor.withValues(alpha: 0.40);
        }
        return foregroundColor;
      }),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        final resolved = fillColor.withValues(alpha: fillOpacity);
        if (states.contains(WidgetState.disabled)) {
          return resolved.withValues(alpha: 0.42);
        }
        return resolved;
      }),
      surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
      shadowColor: const WidgetStatePropertyAll(Colors.transparent),
      elevation: const WidgetStatePropertyAll(0),
      iconSize: WidgetStatePropertyAll(iconSize),
      minimumSize: WidgetStatePropertyAll(minimumSize),
      padding: WidgetStatePropertyAll(padding),
      shape: WidgetStatePropertyAll(shape),
      side: side == null
          ? null
          : WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) {
                return side.copyWith(color: side.color.withValues(alpha: 0.26));
              }
              return side;
            }),
      textStyle: const WidgetStatePropertyAll(
        TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.65,
          height: 1.0,
        ),
      ),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return foregroundColor.withValues(alpha: 0.12);
        }
        if (states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.focused)) {
          return foregroundColor.withValues(alpha: 0.08);
        }
        return Colors.transparent;
      }),
    );
  }
}

class AppFloatingSurface extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final Gradient? gradient;
  final double borderRadius;
  final double amplitude;
  final double phase;
  final bool showShadow;

  const AppFloatingSurface({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor,
    this.borderColor,
    this.gradient,
    this.borderRadius = 20,
    this.amplitude = 3.2,
    this.phase = 0,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fillColor = backgroundColor ?? theme.cardColor;
    final strokeColor = borderColor ?? theme.dividerColor;

    final surfaceChild = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: gradient == null ? fillColor : null,
            gradient: gradient,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: strokeColor.withValues(alpha: 0.92),
              width: 1.1,
            ),
          ),
          child: onTap == null
              ? Padding(padding: padding, child: child)
              : InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(borderRadius),
                  child: Padding(padding: padding, child: child),
                ),
        ),
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ]
            : const [],
      ),
      child: surfaceChild,
    );
  }
}

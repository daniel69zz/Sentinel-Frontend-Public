import 'dart:math' as math;

import 'package:flutter/material.dart';

class AppDesignMotion extends StatefulWidget {
  final Widget child;

  const AppDesignMotion({super.key, required this.child});

  static Animation<double>? maybeOf(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<_AppDesignMotionScope>();
    return scope?.animation;
  }

  @override
  State<AppDesignMotion> createState() => _AppDesignMotionState();
}

class _AppDesignMotionState extends State<AppDesignMotion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _AppDesignMotionScope(animation: _controller, child: widget.child);
  }
}

class _AppDesignMotionScope extends InheritedNotifier<Animation<double>> {
  final Animation<double> animation;

  const _AppDesignMotionScope({required this.animation, required super.child})
    : super(notifier: animation);
}

class AppDesignTheme {
  static ButtonStyle elevatedButtonStyle({
    required Color fillColor,
    required Color foregroundColor,
    required Color shadowColor,
  }) {
    return _floatingButtonStyle(
      fallbackFillColor: fillColor,
      foregroundColor: foregroundColor,
      shadowColor: shadowColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      phase: 0,
    );
  }

  static ButtonStyle filledButtonStyle({
    required Color fillColor,
    required Color foregroundColor,
    required Color shadowColor,
  }) {
    return _floatingButtonStyle(
      fallbackFillColor: fillColor,
      foregroundColor: foregroundColor,
      shadowColor: shadowColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      phase: math.pi / 3,
    );
  }

  static ButtonStyle outlinedButtonStyle({
    required Color fillColor,
    required Color foregroundColor,
    required Color borderColor,
    required Color shadowColor,
  }) {
    return _floatingButtonStyle(
      fallbackFillColor: fillColor,
      foregroundColor: foregroundColor,
      shadowColor: shadowColor,
      fillOpacity: 0.18,
      amplitude: 2.8,
      phase: math.pi / 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      side: BorderSide(color: borderColor, width: 1.15),
    );
  }

  static ButtonStyle textButtonStyle({
    required Color fillColor,
    required Color foregroundColor,
    required Color shadowColor,
  }) {
    return _floatingButtonStyle(
      fallbackFillColor: fillColor,
      foregroundColor: foregroundColor,
      shadowColor: shadowColor,
      fillOpacity: 0.16,
      amplitude: 2.4,
      phase: math.pi,
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
    return _floatingButtonStyle(
      fallbackFillColor: fillColor,
      foregroundColor: foregroundColor,
      shadowColor: shadowColor,
      fillOpacity: 0.88,
      amplitude: 2.6,
      phase: math.pi / 4,
      padding: const EdgeInsets.all(12),
      minimumSize: const Size(48, 48),
      shape: const CircleBorder(),
      side: BorderSide(color: borderColor, width: 1),
      iconSize: 21,
    );
  }

  static ButtonStyle _floatingButtonStyle({
    required Color fallbackFillColor,
    required Color foregroundColor,
    required Color shadowColor,
    required OutlinedBorder shape,
    BorderSide? side,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(
      horizontal: 22,
      vertical: 16,
    ),
    Size minimumSize = const Size(0, 58),
    double fillOpacity = 1,
    double amplitude = 3.2,
    double phase = 0,
    double iconSize = 20,
  }) {
    return ButtonStyle(
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return foregroundColor.withValues(alpha: 0.40);
        }
        return foregroundColor;
      }),
      backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
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
      backgroundBuilder: (context, states, child) {
        return _FloatingButtonLayer(
          animation:
              AppDesignMotion.maybeOf(context) ??
              const AlwaysStoppedAnimation<double>(0),
          states: states,
          fallbackFillColor: fallbackFillColor,
          fallbackShape: shape,
          shadowColor: shadowColor,
          fillOpacity: fillOpacity,
          amplitude: amplitude,
          phase: phase,
          side: side,
          child: child ?? const SizedBox.shrink(),
        );
      },
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
    final animation =
        AppDesignMotion.maybeOf(context) ??
        const AlwaysStoppedAnimation<double>(0);
    final theme = Theme.of(context);
    final fillColor = backgroundColor ?? theme.cardColor;
    final strokeColor = borderColor ?? theme.dividerColor;
    final surfaceGradient =
        gradient ??
        LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(fillColor, Colors.white, 0.05) ?? fillColor,
            Color.lerp(fillColor, Colors.black, 0.08) ?? fillColor,
          ],
        );

    final surfaceChild = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            gradient: surfaceGradient,
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

    return AnimatedBuilder(
      animation: animation,
      child: surfaceChild,
      builder: (context, animatedChild) {
        final glowColor = theme.colorScheme.primary;
        final supportGlow = theme.colorScheme.secondary;
        final dy =
            math.sin((animation.value * math.pi * 2) + phase) * amplitude;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Transform.translate(
            offset: Offset(0, dy),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                boxShadow: showShadow
                    ? [
                        BoxShadow(
                          color: glowColor.withValues(alpha: 0.18),
                          blurRadius: 28,
                          offset: const Offset(0, 16),
                        ),
                        BoxShadow(
                          color: supportGlow.withValues(alpha: 0.10),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.14),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ]
                    : const [],
              ),
              child: animatedChild,
            ),
          ),
        );
      },
    );
  }
}

class _FloatingButtonLayer extends StatelessWidget {
  final Animation<double> animation;
  final Set<WidgetState> states;
  final Widget child;
  final Color fallbackFillColor;
  final OutlinedBorder fallbackShape;
  final Color shadowColor;
  final double fillOpacity;
  final double amplitude;
  final double phase;
  final BorderSide? side;

  const _FloatingButtonLayer({
    required this.animation,
    required this.states,
    required this.child,
    required this.fallbackFillColor,
    required this.fallbackShape,
    required this.shadowColor,
    required this.fillOpacity,
    required this.amplitude,
    required this.phase,
    required this.side,
  });

  @override
  Widget build(BuildContext context) {
    final material = context.findAncestorWidgetOfExactType<Material>();
    final materialColor = material?.color;
    final baseShape = material?.shape is OutlinedBorder
        ? material!.shape as OutlinedBorder
        : fallbackShape;
    final decoratedShape = side == null
        ? baseShape
        : _shapeWithSide(baseShape, side!);

    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, animatedChild) {
        final disabled = states.contains(WidgetState.disabled);
        final pressed = states.contains(WidgetState.pressed);
        final rawFill = materialColor == null || materialColor.a == 0
            ? fallbackFillColor.withValues(alpha: fillOpacity)
            : materialColor;
        final fill = disabled ? rawFill.withValues(alpha: 0.42) : rawFill;
        final dy = disabled
            ? 0.0
            : pressed
            ? amplitude * 0.45
            : math.sin((animation.value * math.pi * 2) + phase) * amplitude;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Transform.translate(
            offset: Offset(0, dy),
            child: DecoratedBox(
              decoration: ShapeDecoration(
                color: fill,
                shape: decoratedShape,
                shadows: disabled
                    ? const []
                    : [
                        BoxShadow(
                          color: shadowColor.withValues(
                            alpha: pressed ? 0.18 : 0.34,
                          ),
                          blurRadius: pressed ? 12 : 22,
                          offset: Offset(0, pressed ? 7 : 12),
                        ),
                      ],
              ),
              child: animatedChild,
            ),
          ),
        );
      },
    );
  }
}

OutlinedBorder _shapeWithSide(OutlinedBorder shape, BorderSide side) {
  if (shape is RoundedRectangleBorder) {
    return shape.copyWith(side: side);
  }
  if (shape is StadiumBorder) {
    return StadiumBorder(side: side);
  }
  if (shape is CircleBorder) {
    return CircleBorder(side: side);
  }
  if (shape is ContinuousRectangleBorder) {
    return shape.copyWith(side: side);
  }
  if (shape is BeveledRectangleBorder) {
    return shape.copyWith(side: side);
  }

  return shape;
}

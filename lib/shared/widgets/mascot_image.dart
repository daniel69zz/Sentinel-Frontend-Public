import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';

class MascotImage extends StatelessWidget {
  final double width;
  final double height;
  final BoxFit fit;
  final EdgeInsetsGeometry padding;
  final String? semanticsLabel;
  final int? level;

  const MascotImage({
    super.key,
    required this.width,
    required this.height,
    this.fit = BoxFit.contain,
    this.padding = EdgeInsets.zero,
    this.semanticsLabel,
    this.level,
  });

  @override
  Widget build(BuildContext context) {
    final path = level == null
        ? AppConstants.mascotPath
        : AppConstants.mascotForLevel(level!);

    return Padding(
      padding: padding,
      child: Image.asset(
        path,
        width: width,
        height: height,
        fit: fit,
        filterQuality: FilterQuality.high,
        semanticLabel: semanticsLabel,
      ),
    );
  }
}

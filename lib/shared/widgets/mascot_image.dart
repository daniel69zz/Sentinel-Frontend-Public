import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';

class MascotImage extends StatelessWidget {
  final double width;
  final double height;
  final BoxFit fit;
  final EdgeInsetsGeometry padding;
  final String? semanticsLabel;

  const MascotImage({
    super.key,
    required this.width,
    required this.height,
    this.fit = BoxFit.contain,
    this.padding = EdgeInsets.zero,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Image.asset(
        AppConstants.mascotPath,
        width: width,
        height: height,
        fit: fit,
        filterQuality: FilterQuality.high,
        semanticLabel: semanticsLabel,
      ),
    );
  }
}

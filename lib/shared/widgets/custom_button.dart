import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

enum ButtonVariant { primary, secondary, outline, danger, ghost }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;
  final double? height;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.fullWidth = true,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final w = _buildButton();
    return fullWidth ? SizedBox(width: double.infinity, child: w) : w;
  }

  Color get _bgColor {
    switch (variant) {
      case ButtonVariant.primary:
        return AppTheme.primary;
      case ButtonVariant.secondary:
        return AppTheme.cardBg;
      case ButtonVariant.outline:
        return Colors.transparent;
      case ButtonVariant.danger:
        return AppTheme.error;
      case ButtonVariant.ghost:
        return Colors.transparent;
    }
  }

  Color get _fgColor {
    switch (variant) {
      case ButtonVariant.primary:
      case ButtonVariant.danger:
        return Colors.white;
      case ButtonVariant.secondary:
        return AppTheme.textPrimary;
      case ButtonVariant.outline:
        return AppTheme.primary;
      case ButtonVariant.ghost:
        return AppTheme.textSecondary;
    }
  }

  BorderSide get _border {
    switch (variant) {
      case ButtonVariant.outline:
        return const BorderSide(color: AppTheme.primary, width: 1.5);
      case ButtonVariant.secondary:
        return const BorderSide(color: AppTheme.divider, width: 1);
      default:
        return BorderSide.none;
    }
  }

  Widget _buildButton() {
    return SizedBox(
      height: height ?? 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _bgColor,
          foregroundColor: _fgColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: _border,
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: _fgColor,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18, color: _fgColor),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _fgColor,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

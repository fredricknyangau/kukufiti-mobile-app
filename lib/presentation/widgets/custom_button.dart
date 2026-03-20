import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum CustomButtonVariant {
  primary,
  secondary,
  outline,
  ghost,
  destructive,
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final CustomButtonVariant variant;
  final bool isLoading;
  final Widget? icon;
  final bool hapticFeedback;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = CustomButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.hapticFeedback = true,
  });

  void _handlePress() {
    if (isLoading) return;
    if (hapticFeedback) {
      HapticFeedback.lightImpact();
    }
    onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color backgroundColor;
    Color foregroundColor;
    BorderSide? borderSide;

    switch (variant) {
      case CustomButtonVariant.primary:
        backgroundColor = colorScheme.primary;
        foregroundColor = colorScheme.onPrimary;
        break;
      case CustomButtonVariant.secondary:
        backgroundColor = colorScheme.secondary;
        foregroundColor = colorScheme.onSecondary;
        break;
      case CustomButtonVariant.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = colorScheme.onSurface;
        borderSide = BorderSide(color: colorScheme.outline);
        break;
      case CustomButtonVariant.ghost:
        backgroundColor = Colors.transparent;
        foregroundColor = colorScheme.onSurface;
        break;
      case CustomButtonVariant.destructive:
        backgroundColor = colorScheme.error;
        foregroundColor = colorScheme.onError;
        break;
    }

    final content = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: foregroundColor,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ],
          );

    if (variant == CustomButtonVariant.outline || variant == CustomButtonVariant.ghost) {
      return TextButton(
        onPressed: isLoading ? null : _handlePress,
        style: TextButton.styleFrom(
          foregroundColor: foregroundColor,
          side: borderSide,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        child: content,
      );
    }

    return ElevatedButton(
      onPressed: isLoading ? null : _handlePress,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        shadowColor: variant == CustomButtonVariant.primary ? colorScheme.primary.withValues(alpha: 0.2) : Colors.transparent,
        elevation: variant == CustomButtonVariant.primary ? 4 : 0,
        side: borderSide,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      child: content,
    );
  }
}

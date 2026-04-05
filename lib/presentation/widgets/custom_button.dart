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
  final VoidCallback? onPressed;
  final CustomButtonVariant variant;
  final bool isLoading;
  final Widget? icon;
  final bool hapticFeedback;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
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
    onPressed?.call();
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
        foregroundColor = colorScheme.primary;
        borderSide = BorderSide(color: colorScheme.primary.withValues(alpha: 0.5), width: 1.5);
        break;
      case CustomButtonVariant.ghost:
        backgroundColor = Colors.transparent;
        foregroundColor = colorScheme.primary;
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

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: variant == CustomButtonVariant.primary
            ? [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                )
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: (isLoading || onPressed == null) ? null : _handlePress,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 0,
          side: borderSide,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        ),
        child: Ink(
          decoration: variant == CustomButtonVariant.primary
              ? BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                )
              : null,
          child: content,
        ),
      ),
    );

  }
}

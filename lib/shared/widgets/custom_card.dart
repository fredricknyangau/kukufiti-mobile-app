import 'package:flutter/material.dart';
import 'dart:ui';


class CustomCard extends StatelessWidget {
  final Widget child;
  final bool isPremium;
  final bool isGlass;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  const CustomCard({
    super.key,
    required this.child,
    this.isPremium = false,
    this.isGlass = false,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // .glass-panel corresponding styling
    if (isGlass) {
      return GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              margin: margin,
              padding: padding,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: isDark ? 0.3 : 0.7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.colorScheme.onSurface.withValues(alpha: isDark ? 0.1 : 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: child,
            ),
          ),
        ),
      );
    }

    // .card-premium styling
    if (isPremium) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          margin: margin,
          padding: padding,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.15 : 0.08),
                blurRadius: 30,
                offset: const Offset(0, 12),
                spreadRadius: -4,
              ),
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      );
    }

    // Default card
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin,
        padding: padding,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 16,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            )
          ],
        ),
        child: child,
      ),
    );
  }
}

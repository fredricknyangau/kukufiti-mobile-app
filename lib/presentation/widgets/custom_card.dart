import 'package:flutter/material.dart';

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

    // .glass-panel corresponding styling
    if (isGlass) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          margin: margin,
          padding: padding,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: child,
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
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 6),
              )
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
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: child,
      ),
    );
  }
}

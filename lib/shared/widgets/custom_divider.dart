import 'package:flutter/material.dart';

class CustomDivider extends StatelessWidget {
  final double height;
  final double indent;
  final double endIndent;

  const CustomDivider({
    super.key,
    this.height = 16,
    this.indent = 0,
    this.endIndent = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 1,
      margin: EdgeInsets.only(
        top: height / 2,
        bottom: height / 2,
        left: indent,
        right: endIndent,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.0),
            theme.colorScheme.primary.withValues(alpha: isDark ? 0.35 : 0.15),
            theme.colorScheme.primary.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }
}

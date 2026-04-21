import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PublicMeshBackground extends StatelessWidget {
  final Widget child;

  const PublicMeshBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      children: [
        // ─── BACKGROUND ADAPTIVE MESH ───
        Positioned.fill(
          child: Container(color: theme.colorScheme.surface),
        ),
        
        // Soft Glowing Primary Sphere at Top Right
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary.withValues(
                alpha: isDark ? 0.12 : 0.08,
              ),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true))
           .move(
             begin: const Offset(0, 0), 
             end: const Offset(-20, 30), 
             duration: 8.seconds, 
             curve: Curves.easeInOut,
           ),
        ),
        
        // Soft Glowing Orange/Amber Sphere at Center Left
        Positioned(
          top: 250,
          left: -150,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.orange.withValues(
                alpha: isDark ? 0.08 : 0.05,
              ),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true))
           .move(
             begin: const Offset(0, 0), 
             end: const Offset(40, -20), 
             duration: 10.seconds, 
             curve: Curves.easeInOut,
           ),
        ),

        // Gradient Overlay for Depth
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.surface.withValues(alpha: 0.0),
                  theme.colorScheme.surface.withValues(alpha: 0.2),
                  theme.colorScheme.surface.withValues(alpha: 0.8),
                  theme.colorScheme.surface,
                ],
                stops: const [0.0, 0.4, 0.8, 1.0],
              ),
            ),
          ),
        ),
        
        child,
      ],
    );
  }
}

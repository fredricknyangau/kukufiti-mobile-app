import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../providers/data_providers.dart';
import '../../core/theme/app_theme.dart';

class PremiumGate extends ConsumerWidget {
  final Widget child;
  final String featureKey;
  final String featureName;

  const PremiumGate({
    super.key,
    required this.child,
    required this.featureKey,
    required this.featureName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subDetailsAsync = ref.watch(planDetailsProvider);
    
    return subDetailsAsync.when(
      data: (plan) {
        final profile = ref.watch(profileProvider).value;
        if (profile?.isAdmin == true) return child;
        
        final features = List<String>.from(plan['features'] ?? []);
        final hasAccess = features.contains(featureKey);

        if (hasAccess) return child;

        // Determine appropriate tier for the UI message
        String targetTier = 'Professional';
        if (['ai_advisory', 'ai_chat', 'multi_farm', 'audit_logs'].contains(featureKey)) {
          targetTier = 'Enterprise';
        }

        final theme = Theme.of(context);
        final customColors = theme.extension<CustomColors>();

        return Stack(
          children: [
            AbsorbPointer(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: child,
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.scrim.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.shadow.withValues(alpha: 0.12),
                            blurRadius: 10,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: Icon(
                        targetTier == 'Enterprise' ? LucideIcons.gem : LucideIcons.lock,
                        color: targetTier == 'Enterprise' ? customColors?.purple : customColors?.warning,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '$featureName is Premium',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Absolute white for overlay contrast
                        shadows: [Shadow(blurRadius: 4, color: Colors.black.withValues(alpha: 0.45))], // Fixed contrast shadow
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        context.push('/pricing'); 
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Text('Upgrade to $targetTier'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => child, // Fallback on error
    );
  }
}

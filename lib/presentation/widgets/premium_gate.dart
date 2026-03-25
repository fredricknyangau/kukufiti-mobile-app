import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../providers/data_providers.dart';

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
        final features = List<String>.from(plan['features'] ?? []);
        final hasAccess = features.contains(featureKey);

        if (hasAccess) return child;

        // Determine appropriate tier for the UI message
        String targetTier = 'Professional';
        if (['ai_advisory', 'ai_chat', 'multi_farm', 'audit_logs'].contains(featureKey)) {
          targetTier = 'Enterprise';
        }

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
                  color: Colors.black.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: Icon(
                        targetTier == 'Enterprise' ? LucideIcons.gem : LucideIcons.lock,
                        color: targetTier == 'Enterprise' ? Colors.purple : Colors.orange,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '$featureName is Premium',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [Shadow(blurRadius: 4, color: Colors.black45)],
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        context.push('/pricing'); 
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
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

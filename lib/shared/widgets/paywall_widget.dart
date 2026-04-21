import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mobile/shared/widgets/custom_button.dart';
import 'package:mobile/shared/widgets/custom_card.dart';

class PaywallWidget extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const PaywallWidget({
    super.key,
    required this.title,
    required this.description,
    this.icon = LucideIcons.shieldAlert,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                size: 48,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            CustomCard(
              isPremium: true,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Upgrade to unlock this feature',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'View Plans & Upgrade',
                    onPressed: () {
                      context.push('/pricing');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

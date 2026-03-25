import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Last Updated: March 2026',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            _buildSection(
              theme,
              '1. Acceptance of Terms',
              'By accessing and using KukuFiti, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the application.',
            ),
            _buildSection(
              theme,
              '2. Purpose of the App',
              'KukuFiti is a poultry management tool designed to help farmers track flocks, finance, and health data. The app is provided "as is" and its data should be used as a management aid, not a substitute for professional veterinary or financial advice.',
            ),
            _buildSection(
              theme,
              '3. User Data & Privacy',
              'Your data is stored securely. We do not sell your farming data to third parties. You are responsible for maintaining the confidentiality of your account credentials.',
            ),
            _buildSection(
              theme,
              '4. Subscription & Billing',
              'Subscriptions are managed through your M-Pesa account. Cancellations will apply to the following billing cycle. No refunds for partial months.',
            ),
            _buildSection(
              theme,
              '5. Limitation of Liability',
              'KukuFiti and its developers shall not be liable for any loss of livestock, financial loss, or data loss resulting from the use of this software.',
            ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                '© 2026 KukuFiti. All rights reserved.',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(ThemeData theme, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../widgets/custom_button.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_input.dart';
import '../../widgets/public_drawer.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      drawer: const PublicDrawer(),
      appBar: AppBar(
        title: const Text('Contact Sales', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            bottom: -50,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.12 : 0.06),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.messageCircle, size: 48, color: Colors.blueAccent),
                      const SizedBox(height: 16),
                      const Text(
                        'Have a question?',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'We would love to hear from you or help scale layout.',
                        style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      // ─── CONTACT INFORMATION ───
                      _buildContactDetailItem(LucideIcons.mail, 'Email', 'support@kukufiti.com', theme),
                      const SizedBox(height: 12),
                      _buildContactDetailItem(LucideIcons.phone, 'Phone', '+254 700 000 000', theme),
                      const SizedBox(height: 12),
                      _buildContactDetailItem(LucideIcons.mapPin, 'Office', 'Nairobi Garage, Westlands', theme),
                      const SizedBox(height: 32),
                      CustomCard(
                        isPremium: true,
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            CustomInput(
                              label: 'Name',
                              hintText: 'Your name',
                              controller: TextEditingController(),
                            ),
                            const SizedBox(height: 16),
                            CustomInput(
                              label: 'Email',
                              hintText: 'your@email.com',
                              keyboardType: TextInputType.emailAddress,
                              controller: TextEditingController(),
                            ),
                            const SizedBox(height: 16),
                            CustomInput(
                              label: 'Message',
                              hintText: 'How can we help?',
                              controller: TextEditingController(),
                            ),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              child: CustomButton(
                                text: 'Send Message',
                                onPressed: () {},
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildContactDetailItem(IconData icon, String title, String value, ThemeData theme) {
    return CustomCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/public_drawer.dart';
import '../../widgets/public_mesh_background.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      drawer: const PublicDrawer(),
      appBar: AppBar(
        title: const Text('Contact Us', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: PublicMeshBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 16),
                const Text(
                  'Get in Touch',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
                const SizedBox(height: 8),
                Text(
                  'Have questions? We\'d love to hear from you.',
                  style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
                const SizedBox(height: 32),

                // ─── CONTACT FORM ───
                CustomCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTextField(theme, 'Full Name', 'e.g. John Doe'),
                      const SizedBox(height: 16),
                      _buildTextField(theme, 'Email Address', 'e.g. john@example.com'),
                      const SizedBox(height: 16),
                      _buildTextField(theme, 'Message', 'How can we help you?', maxLines: 4),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: 'Send Message',
                        onPressed: () {},
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
                const SizedBox(height: 32),

                // ─── CONTACT INFO GRID ───
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        theme,
                        LucideIcons.mail,
                        'Email Us',
                        'support@kukufiti.com',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoCard(
                        theme,
                        LucideIcons.phone,
                        'Call Us',
                        '+254 700 123 456',
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 600.ms),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(ThemeData theme, String label, String hint, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 8),
        TextField(
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(ThemeData theme, IconData icon, String title, String value) {
    return CustomCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 20),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

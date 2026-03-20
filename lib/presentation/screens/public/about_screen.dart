import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../widgets/custom_card.dart';
import '../../widgets/public_drawer.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      drawer: const PublicDrawer(),
      appBar: AppBar(
        title: const Text('About Us', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -50,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.15 : 0.08),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'Digitizing Poultry Farming',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Built by farmers, driven by intelligence.',
                    style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  _buildInfoCard(
                    theme: theme,
                    icon: LucideIcons.rocket,
                    title: 'Our Mission',
                    desc: 'To digitize poultry farming across Africa, bringing enterprise-grade analytics to smallholder and commercial operations alike to double yield and revenue multipliers.',
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    theme: theme,
                    icon: LucideIcons.users,
                    title: 'The Team',
                    desc: 'Headquartered in Nairobi, Kenya, our team combines decades of deep agricultural expertise with cutting-edge software engineering to solve real-world daily problems layout.',
                    color: Colors.teal,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    theme: theme,
                    icon: LucideIcons.heart,
                    title: 'Our Values',
                    desc: 'We prioritse sustainability, operational accountability, and farmer-first development cycles above everything else flawlessly setup background mesh glows container lift.',
                    color: Colors.pinkAccent,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String desc,
    required Color color,
  }) {
    return CustomCard(
      isPremium: true,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          const SizedBox(height: 8),
          Text(
            desc,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

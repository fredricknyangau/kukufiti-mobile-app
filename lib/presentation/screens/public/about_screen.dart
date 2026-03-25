import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/public_drawer.dart';
import '../../widgets/public_mesh_background.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      drawer: const PublicDrawer(),
      appBar: AppBar(
        title: const Text('About Us', style: TextStyle(fontWeight: FontWeight.bold)),
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                const Text(
                  'Empowering the Modern Farmer',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
                const SizedBox(height: 8),
                Text(
                  'We are on a mission to democratize access to professional-grade tools for poultry farmers across Africa.',
                  style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
                const SizedBox(height: 40),

                // ─── OUR STORY ───
                CustomCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Our Story',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: theme.colorScheme.primary),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Founded in 2025, KukuFiti was born out of a simple observation: poultry farming is huge business, but small and medium-sized farmers often lack the tools to compete with large integrators.',
                        style: TextStyle(height: 1.5, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'We saw farmers tracking thousands of birds with notebook and pen, often realizing too late that feed conversion was off. We built KukuFiti to change that.',
                        style: TextStyle(height: 1.5, fontSize: 14),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
                const SizedBox(height: 32),

                // ─── CORE VALUES ───
                const Text(
                  'Our Core Values',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildValueSmallCard(context, 'Farmer First', 'We build for muddy boots, not inside boardrooms.', theme),
                    _buildValueSmallCard(context, 'Data Integrity', 'Precision is our promise. Your data is accurate.', theme),
                    _buildValueSmallCard(context, 'Simplicity', 'Complex tech, simple interface. No manual required.', theme),
                    _buildValueSmallCard(context, 'Sustainability', 'Profitable farms are sustainable farms.', theme),
                  ],
                ),
                const SizedBox(height: 32),

                // ─── MEET THE TEAM ───
                const Text(
                  'Meet the Team',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ...[
                  {
                    'name': 'David Kimani',
                    'role': 'Co-Founder & CEO',
                    'bio': 'Former commercial poultry farmer turned tech entrepreneur. David understands the struggles.'
                  },
                  {
                    'name': 'Sarah Wanjiku',
                    'role': 'Head of Agronomy',
                    'bio': 'Veterinary surgeon with 10+ years specializing in avian health.'
                  },
                  {
                    'name': 'Michael Omondi',
                    'role': 'Lead Engineer',
                    'bio': 'Full-stack wizard building robust systems keeping your data safe and accessible 24/7.'
                  },
                  {
                    'name': 'Grace Nyambura',
                    'role': 'Customer Success',
                    'bio': 'Dedicated to ensuring every farmer gets the most out of KukuFiti daily.'
                  },
                ].map((m) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: CustomCard(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                              child: Text(
                                m['name']![0],
                                style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(m['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text(m['role']!, style: TextStyle(color: theme.colorScheme.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Text(
                                    m['bio']!,
                                    style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )).toList(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildValueSmallCard(
    BuildContext context,
    String title,
    String desc,
    ThemeData theme,
  ) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 60) / 2, // 2 items per row
      child: CustomCard(
        isPremium: true,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              desc,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 12,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

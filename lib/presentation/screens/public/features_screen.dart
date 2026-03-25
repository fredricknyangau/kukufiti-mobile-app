import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/public_drawer.dart';
import '../../widgets/public_mesh_background.dart';

class FeaturesScreen extends StatelessWidget {
  const FeaturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<Map<String, dynamic>> items = [
      {'title': 'Financial Analytics', 'desc': 'Gain deep insights into your farm\'s profitability per batch.', 'icon': LucideIcons.barChart3, 'color': theme.colorScheme.primary},
      {'title': 'Mortality Monitoring', 'desc': 'Log daily mortality trends and receive automated threshold alerts.', 'icon': LucideIcons.activity, 'color': const Color(0xFFF43F5E)},
      {'title': 'Conversion Optimize', 'desc': 'Monitor FCR (Feed Conversion Ratio) in real-time to save feed.', 'icon': LucideIcons.trendingUp, 'color': Colors.blueAccent},
      {'title': 'Biosecurity Logs', 'desc': 'Maintain tamper-proof records of critical safety biosecurity logs.', 'icon': LucideIcons.shieldCheck, 'color': Colors.indigoAccent},
      {'title': 'Task Scheduling', 'desc': 'Schedule vaccinations and routine tasks with integrated reminders.', 'icon': LucideIcons.checkCircle, 'color': Colors.purpleAccent},
      {'title': 'Team Collaboration', 'desc': 'Assign roles and permissions to staff and farm managers.', 'icon': LucideIcons.users, 'color': Colors.tealAccent},
      {'title': 'Mobile-First Design', 'desc': 'Manage your farm from field using optimized responsive setup.', 'icon': LucideIcons.smartphone, 'color': Colors.cyan},
      {'title': 'Cloud Backup', 'desc': 'Automatic cloud backups and enterprise-grade security safety.', 'icon': LucideIcons.cloud, 'color': Colors.blueGrey},
      {'title': 'Real-time Alerts', 'desc': 'React instantly to missed vaccinations or mortality triggers.', 'icon': LucideIcons.clock, 'color': Colors.orangeAccent},
    ];

    return Scaffold(
      drawer: const PublicDrawer(),
      appBar: AppBar(
        title: const Text('Features', style: TextStyle(fontWeight: FontWeight.bold)),
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
                const Text(
                  'Everything to run a profitable farm',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
                const SizedBox(height: 8),
                Text(
                  'Modular endpoints built for scalable commercial poultry operations.',
                  style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
                const SizedBox(height: 40),
                
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final itemColor = item['color'] as Color;
                    return SizedBox(
                      width: (MediaQuery.of(context).size.width - 64) / 2, // 2 items per row with 16 spacing
                      child: CustomCard(
                        isPremium: true,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: itemColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(item['icon'] as IconData, color: itemColor, size: 24),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              item['title'].toString(),
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item['desc'].toString(),
                              style: TextStyle(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                fontSize: 12,
                                height: 1.4,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: (400 + index * 50).ms, duration: 500.ms).slideY(begin: 0.1, end: 0);
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

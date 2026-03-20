import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/public_drawer.dart';

class FeaturesScreen extends StatelessWidget {
  const FeaturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final List<Map<String, dynamic>> items = [
      {'title': 'Flock Management', 'desc': 'Track daily mortality, feed consumption, and growth metrics accurately.', 'icon': LucideIcons.layers, 'color': Colors.blue},
      {'title': 'Finance Tracker', 'desc': 'Log expenses and sales to identify exact real-time margins.', 'icon': LucideIcons.coins, 'color': Colors.teal},
      {'title': 'Smart Alerts', 'desc': 'Real-time push notifications when threshold limits are breached.', 'icon': LucideIcons.bellRing, 'color': Colors.amber},
      {'title': 'Inventory Ledger', 'desc': 'Auto-updating stock for feeds, vaccines, and supplements.', 'icon': LucideIcons.package, 'color': Colors.indigo},
      {'title': 'Audit Logs', 'desc': 'Track all security changes for accountability across workforce.', 'icon': LucideIcons.shieldCheck, 'color': Colors.teal},
      {'title': 'Reports Export', 'desc': 'PDF and Spreadsheet generation for banking & tax ready documentation.', 'icon': LucideIcons.fileSpreadsheet, 'color': Colors.redAccent},
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
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -50,
            left: -100,
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
                  const Text(
                    'Everything to run a profitable farm',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Modular endpoints built for scalable commercial poultry operations.',
                    style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: items.map((item) {
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
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

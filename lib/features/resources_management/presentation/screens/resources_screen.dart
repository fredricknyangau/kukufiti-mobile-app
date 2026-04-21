import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:mobile/shared/widgets/app_drawer.dart';
import 'package:mobile/shared/widgets/custom_card.dart';
import 'package:mobile/shared/providers/data_providers.dart';

class ResourcesScreen extends ConsumerWidget {
  const ResourcesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resourcesAsync = ref.watch(resourcesProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Farm Resources', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: resourcesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error loading resources: ${e.toString().split('\n').first}')),
        data: (guides) {
          if (guides.isEmpty) {
            return const Center(child: Text('No resources available.'));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(resourcesProvider),
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: guides.length,
              itemBuilder: (context, index) {
                final guide = guides[index];
                IconData iconData = LucideIcons.bookOpen;
                if (guide['icon'] == 'syringe') iconData = LucideIcons.syringe;
                if (guide['icon'] == 'alertTriangle') iconData = LucideIcons.alertTriangle;
                if (guide['icon'] == 'wheat') iconData = LucideIcons.wheat;

                return _buildResourceCard(
                  context,
                  guide['title']?.toString() ?? 'Guide',
                  guide['description']?.toString() ?? '',
                  guide['content']?.toString() ?? '',
                  iconData,
                );
              },
            ),
          );

        },
      ),
    );
  }

  Widget _buildResourceCard(BuildContext context, String title, String subtitle, String content, IconData icon) {
    final theme = Theme.of(context);
    return CustomCard(
      isPremium: true,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              subtitle,
              style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 11),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
               onPressed: () => _showGuideViewer(context, title, content),
               icon: const Icon(LucideIcons.bookOpen, size: 14),
               label: const Text('Read Guide', style: TextStyle(fontSize: 12)),
               style: TextButton.styleFrom(
                 padding: EdgeInsets.zero,
                 alignment: Alignment.centerLeft,
               ),
            ),
          )
        ],
      ),
    );
  }

  void _showGuideViewer(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Text(content, style: const TextStyle(height: 1.5)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../presentation/widgets/app_drawer.dart';
import '../../../../presentation/widgets/custom_card.dart';

class ResourcesScreen extends StatelessWidget {
  const ResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> guides = [
      {
        'title': 'Broiler Management Guide',
        'category': 'General',
        'icon': 'bookOpen',
        'description': 'Comprehensive guide for managing broilers from day 1 to market.',
        'content': 'Broilers require careful management of temperature, air quality, water, and feed. During the first week (brooding), temperature should be maintained at 32-34°C. Provide clean bedding and access to fresh water at all times. Ventilate well as they grow.'
      },
      {
        'title': 'Vaccination Schedule',
        'category': 'Health',
        'icon': 'syringe',
        'description': 'Recommended vaccination program for commercial broilers.',
        'content': 'Day 1: Marek\'s Disease (Hatchery). Day 7: Newcastle Disease (B1/LaSota) + Infectious Bronchitis. Day 14: Gumboro (IBD) Intermediate. Day 21: Newcastle Disease (LaSota) Booster. Always consult your local vet.'
      },
      {
        'title': 'Disease Identification',
        'category': 'Health',
        'icon': 'alertTriangle',
        'description': 'Common diseases, symptoms, and immediate actions.',
        'content': 'Coccidiosis: Bloody droppings, huddling. Treat with Amprolium/Sulfa. Newcastle: Twisted necks, respiratory distress. No cure, prevent with vaccine. CRD: Snicking, coughing. Treat with Tylosin/Doxycycline.'
      },
      {
        'title': 'Feeding Program',
        'category': 'Nutrition',
        'icon': 'wheat',
        'description': 'Starter, Grower, and Finisher feed requirements.',
        'content': 'Starter (Day 0-14): High protein (22-23%). Crumble form. Grower (Day 15-28): Balanced energy/protein (20%). Pellet form. Finisher (Day 29+): High energy (18-19%). Pellet form.'
      },
    ];

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Farm Resources', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: GridView.builder(
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
            guide['title']!,
            guide['description']!,
            guide['content']!,
            iconData,
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

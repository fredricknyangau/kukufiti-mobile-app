import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../presentation/widgets/custom_card.dart';
import '../../../../presentation/widgets/premium_gate.dart';
import 'package:go_router/go_router.dart';

class AiAdvisoryHubScreen extends ConsumerWidget {
  const AiAdvisoryHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final List<Map<String, dynamic>> modules = [
      {
        'title': 'Feed Optimizer',
        'desc': 'Target optimal daily nutrition weights',
        'icon': LucideIcons.sparkles,
        'route': '/ai-feed-advisory',
        'color': Colors.deepPurple,
      },
      {
        'title': 'Mortality Analytics',
        'desc': 'Detect anomalous mortality spikes',
        'icon': LucideIcons.trendingDown,
        'route': '/ai-mortality-analysis',
        'color': Colors.deepOrangeAccent,
      },
      {
        'title': 'Harvest Readiness',
        'desc': 'Predict finishing days to target weight',
        'icon': LucideIcons.calendarDays,
        'route': '/ai-harvest-prediction', // will Map these routes shortly
        'color': Colors.teal,
      },
      {
        'title': 'Disease Risk',
        'desc': 'Analyze symptoms or missed vaccines',
        'icon': LucideIcons.shieldAlert,
        'route': '/ai-disease-risk',
        'color': Colors.redAccent,
      },
      {
        'title': 'FCR Insights',
        'desc': 'Assess feed conversion profitability',
        'icon': LucideIcons.calculator,
        'route': '/ai-fcr-insights',
        'color': Colors.indigo,
      },
      {
        'title': 'AI Vet Chatbot',
        'desc': 'East African context-aware farming AI',
        'icon': LucideIcons.messageSquare,
        'route': '/ai-chat',
        'color': Colors.blueAccent,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Advisory Hub', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: PremiumGate(
        featureKey: 'ai_advisory',
        featureName: 'AI Advisory',
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.78,
          ),
          itemCount: modules.length,
          itemBuilder: (context, index) {
            final mod = modules[index];
            final Color modColor = mod['color'];

            return CustomCard(
              isPremium: true,
              child: InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  context.push(mod['route']);
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: modColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(mod['icon'], color: modColor, size: 36),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        mod['title'],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        mod['desc'],
                        style: TextStyle(
                          color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

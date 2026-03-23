import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../presentation/widgets/app_drawer.dart';
import '../../../../presentation/widgets/custom_card.dart';
import '../../../../providers/data_providers.dart';
import '../../../../core/models/broiler_models.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Watch all data streams
    final metricsAsync = ref.watch(dashboardMetricsProvider);
    final financeAsync = ref.watch(financialChartProvider);
    final weightAsync = ref.watch(weightProvider);
    final mortalityAsync = ref.watch(mortalityProvider);

    // Provide a simple unified loading/error state if any is loading
    if (metricsAsync.isLoading || financeAsync.isLoading || weightAsync.isLoading || mortalityAsync.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (metricsAsync.hasError || financeAsync.hasError || weightAsync.hasError || mortalityAsync.hasError) {
      return Scaffold(body: Center(child: Text('Error loading analytics')));
    }

    final metrics = metricsAsync.value ?? {};
    final financeData = financeAsync.value ?? [];
    final List<WeightRecord> weightData = weightAsync.value ?? [];
    final List<MortalityRecord> mortalityDataRaw = mortalityAsync.value ?? [];

    // Process Growth Data
    final sortedWeight = List<WeightRecord>.from(weightData)
      ..sort((a, b) {
        return a.date.compareTo(b.date);
      });
    final weightSpots = <FlSpot>[];
    for(int i=0; i<sortedWeight.length; i++) {
        final weight = sortedWeight[i].averageWeight;
        weightSpots.add(FlSpot(i.toDouble(), weight));
    }

    // Process Mortality Data
    final mortalityData = <BarChartGroupData>[];
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final dayStr = DateFormat('yyyy-MM-dd').format(day);
      final countToday = mortalityDataRaw.where((e) {
        final dateStr = e.date.toIso8601String();
        return dateStr.startsWith(dayStr);
      }).fold<int>(0, (prev, e) => prev + e.count);
      mortalityData.add(BarChartGroupData(x: 6-i, barRods: [BarChartRodData(toY: countToday.toDouble(), color: theme.colorScheme.error)]));
    }

    // Process Financial Data
    final financeSpotsRev = <FlSpot>[];
    final financeSpotsExp = <FlSpot>[];
    for (int i=0; i<financeData.length; i++) {
        financeSpotsRev.add(FlSpot(i.toDouble(), (financeData[i]['revenue'] as num).toDouble()));
        financeSpotsExp.add(FlSpot(i.toDouble(), (financeData[i]['expenses'] as num).toDouble()));
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        drawer: const AppDrawer(),
        appBar: AppBar(
          title: const Text('Performance Analytics', style: TextStyle(fontWeight: FontWeight.bold)),
          bottom: const TabBar(
            dividerColor: Colors.transparent,
            tabs: [
              Tab(text: 'Growth'),
              Tab(text: 'Health'),
              Tab(text: 'Financial'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Growth Tab
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.4,
                  children: [
                    _buildStatCard(
                      context, 
                      'Avg Weight', 
                      sortedWeight.isNotEmpty ? '${(sortedWeight.last.averageWeight / 1000).toStringAsFixed(2)} kg' : 'N/A',
                      icon: LucideIcons.scale,
                      color: theme.colorScheme.primary,
                    ),
                    _buildStatCard(
                      context, 
                      'Mortality Rate', 
                      '${metrics['mortality_rate'] ?? 0}%',
                      icon: LucideIcons.trendingDown,
                      color: theme.colorScheme.error,
                    ),
                    _buildStatCard(
                      context, 
                      'Active Flocks', 
                      '${metrics['active_flocks'] ?? 0}',
                      icon: LucideIcons.layers,
                      color: theme.colorScheme.secondary,
                    ),
                    _buildStatCard(
                      context, 
                      'Total Birds', 
                      '${metrics['current_birds'] ?? 0}',
                      icon: LucideIcons.twitter, // standard bird icon equivalent
                      color: Colors.orange,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                CustomCard(
                  isPremium: true,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           Text('Weight Trends', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                           const Icon(LucideIcons.trendingUp, color: Colors.green, size: 20),
                         ],
                       ),
                       const SizedBox(height: 24),
                       SizedBox(
                         height: 250,
                         child: weightSpots.isEmpty ? const Center(child: Text('No data available')) : LineChart(
                           LineChartData(
                             lineTouchData: LineTouchData(
                               touchTooltipData: LineTouchTooltipData(
                                 getTooltipItems: (touchedSpots) {
                                   return touchedSpots.map((spot) {
                                     return LineTooltipItem(
                                       '${spot.y.toStringAsFixed(1)} g',
                                       const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                     );
                                   }).toList();
                                 },
                               ),
                             ),
                             gridData: FlGridData(
                               show: true,
                               drawVerticalLine: false,
                               getDrawingHorizontalLine: (value) => FlLine(
                                 color: theme.colorScheme.onSurface.withValues(alpha: 0.05), 
                                 strokeWidth: 1,
                               ),
                             ),
                             borderData: FlBorderData(show: false),
                             titlesData: FlTitlesData(
                               show: true,
                               rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                               topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                               bottomTitles: AxisTitles(
                                 sideTitles: SideTitles(
                                   showTitles: true,
                                   reservedSize: 22,
                                   getTitlesWidget: (value, meta) {
                                     final index = value.toInt();
                                     if (index >= 0 && index < sortedWeight.length) {
                                         final date = sortedWeight[index].date;
                                         return Text(DateFormat('dd/MM').format(date), style: const TextStyle(fontSize: 9, color: Colors.grey));
                                     }
                                     return const SizedBox();
                                   },
                                 ),
                               ),
                             ),
                             lineBarsData: [
                               LineChartBarData(
                                 spots: weightSpots,
                                 isCurved: true,
                                 color: theme.colorScheme.primary,
                                 barWidth: 4,
                                 dotData: const FlDotData(show: false),
                                 belowBarData: BarAreaData(
                                   show: true,
                                   gradient: LinearGradient(
                                     colors: [
                                       theme.colorScheme.primary.withValues(alpha: 0.15),
                                       theme.colorScheme.primary.withValues(alpha: 0.0),
                                     ],
                                     begin: Alignment.topCenter,
                                     end: Alignment.bottomCenter,
                                   ),
                                 ),
                               )
                             ]
                           )
                         ),
                       )
                    ],
                  ),
                )
              ],
            ),
            
            // Health Tab
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                 CustomCard(
                  isPremium: true,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           Text('Daily Mortality Trend', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                           const Icon(LucideIcons.alertTriangle, color: Colors.orange, size: 20),
                         ],
                       ),
                       const SizedBox(height: 24),
                       SizedBox(
                         height: 250,
                         child: BarChart(
                           BarChartData(
                             gridData: FlGridData(
                               show: true,
                               drawVerticalLine: false,
                               getDrawingHorizontalLine: (value) => FlLine(
                                 color: theme.colorScheme.onSurface.withValues(alpha: 0.05), 
                                 strokeWidth: 1,
                               ),
                             ),
                             borderData: FlBorderData(show: false),
                             titlesData: FlTitlesData(
                               show: true,
                               rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                               topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                               bottomTitles: AxisTitles(
                                 sideTitles: SideTitles(
                                   showTitles: true,
                                   reservedSize: 22,
                                   getTitlesWidget: (value, meta) {
                                     final index = value.toInt();
                                     if (index >= 0 && index <= 6) {
                                         final day = DateTime.now().subtract(Duration(days: 6 - index));
                                         return Text(DateFormat('E').format(day), style: const TextStyle(fontSize: 9, color: Colors.grey));
                                     }
                                     return const SizedBox();
                                   },
                                 ),
                               ),
                             ),
                             barGroups: mortalityData,
                           )
                         ),
                       )
                    ],
                  ),
                )
              ],
            ),

            // Financial Tab
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                 CustomCard(
                  isPremium: true,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           Text('Revenue vs Expenses', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                           const Icon(LucideIcons.dollarSign, color: Colors.green, size: 20),
                         ],
                       ),
                       const SizedBox(height: 24),
                       SizedBox(
                         height: 250,
                         child: financeSpotsRev.isEmpty ? const Center(child: Text('No data loaded')) : LineChart(
                           LineChartData(
                             lineTouchData: LineTouchData(
                               touchTooltipData: LineTouchTooltipData(
                                 getTooltipItems: (touchedSpots) {
                                   return touchedSpots.map((spot) {
                                     return LineTooltipItem(
                                       spot.y.toStringAsFixed(0),
                                       const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                     );
                                   }).toList();
                                 },
                               ),
                             ),
                             gridData: FlGridData(
                               show: true,
                               drawVerticalLine: false,
                               getDrawingHorizontalLine: (value) => FlLine(
                                 color: theme.colorScheme.onSurface.withValues(alpha: 0.05), 
                                 strokeWidth: 1,
                               ),
                             ),
                             borderData: FlBorderData(show: false),
                             titlesData: FlTitlesData(
                               show: true,
                               rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                               topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                               bottomTitles: AxisTitles(
                                 sideTitles: SideTitles(
                                   showTitles: true,
                                   reservedSize: 22,
                                   getTitlesWidget: (value, meta) {
                                     final index = value.toInt();
                                     if (index >= 0 && index < financeData.length) {
                                         final name = financeData[index]['name']?.toString() ?? '';
                                         return Text(name, style: const TextStyle(fontSize: 9, color: Colors.grey));
                                     }
                                     return const SizedBox();
                                   },
                                 ),
                               ),
                             ),
                             lineBarsData: [
                               LineChartBarData(
                                 spots: financeSpotsRev,
                                 isCurved: true,
                                 color: theme.colorScheme.primary,
                                 barWidth: 4,
                                 dotData: const FlDotData(show: false),
                                 belowBarData: BarAreaData(
                                   show: true, 
                                   gradient: LinearGradient(
                                     colors: [
                                       theme.colorScheme.primary.withValues(alpha: 0.15),
                                       theme.colorScheme.primary.withValues(alpha: 0.0),
                                     ],
                                     begin: Alignment.topCenter,
                                     end: Alignment.bottomCenter,
                                   ),
                                 ),
                               ),
                               LineChartBarData(
                                 spots: financeSpotsExp,
                                 isCurved: true,
                                 color: theme.colorScheme.error,
                                 barWidth: 4,
                                 dotData: const FlDotData(show: false),
                                 belowBarData: BarAreaData(
                                   show: true, 
                                   gradient: LinearGradient(
                                     colors: [
                                       theme.colorScheme.error.withValues(alpha: 0.15),
                                       theme.colorScheme.error.withValues(alpha: 0.0),
                                     ],
                                     begin: Alignment.topCenter,
                                     end: Alignment.bottomCenter,
                                   ),
                                 ),
                               )
                             ]
                           )
                         ),
                       )
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, {required IconData icon, required Color color}) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
         color: theme.colorScheme.surface,
         borderRadius: BorderRadius.circular(16),
         border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
         gradient: LinearGradient(
           colors: [
             color.withValues(alpha: 0.05),
             theme.colorScheme.surface,
           ],
           begin: Alignment.topLeft,
           end: Alignment.bottomRight,
         ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title, 
                style: TextStyle(
                  fontSize: 12, 
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(icon, color: color, size: 18),
            ],
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5),
          ),
        ],
      ),
    );
  }
}

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../presentation/widgets/app_drawer.dart';
import '../../../../presentation/widgets/custom_card.dart';
import '../../../../providers/data_providers.dart';

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
    final weightData = weightAsync.value ?? [];
    final mortalityDataRaw = mortalityAsync.value ?? [];

    // Process Growth Data
    final sortedWeight = List<dynamic>.from(weightData)
      ..sort((a, b) {
        final dateA = DateTime.tryParse(a['event_date']?.toString() ?? '') ?? DateTime(2000);
        final dateB = DateTime.tryParse(b['event_date']?.toString() ?? '') ?? DateTime(2000);
        return dateA.compareTo(dateB);
      });
    final weightSpots = <FlSpot>[];
    for(int i=0; i<sortedWeight.length; i++) {
        final weight = (sortedWeight[i]['average_weight_grams'] as num?)?.toDouble() ?? 0.0;
        weightSpots.add(FlSpot(i.toDouble(), weight));
    }

    // Process Mortality Data
    final mortalityData = <BarChartGroupData>[];
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final dayStr = DateFormat('yyyy-MM-dd').format(day);
      final countToday = mortalityDataRaw.where((e) {
        final dateStr = e['event_date']?.toString() ?? '';
        return dateStr.startsWith(dayStr);
      }).fold<int>(0, (prev, e) => prev + ((e['count'] as num?)?.toInt() ?? 0));
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
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1.5,
                  children: [
                    _buildStatCard(context, 'Avg Weight', sortedWeight.isNotEmpty ? '${((sortedWeight.last['average_weight_grams'] as num?)?.toDouble() ?? 0.0) / 1000} kg' : 'N/A'),
                    _buildStatCard(context, 'Mortality Rate', '${metrics['mortality_rate'] ?? 0}%'),
                    _buildStatCard(context, 'Active Flocks', '${metrics['active_flocks'] ?? 0}'),
                    _buildStatCard(context, 'Total Birds', '${metrics['current_birds'] ?? 0}'),
                  ],
                ),
                const SizedBox(height: 24),
                CustomCard(
                  isPremium: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Text('Weight Trends', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                       const SizedBox(height: 16),
                       SizedBox(
                         height: 250,
                         child: weightSpots.isEmpty ? const Center(child: Text('No data')) : LineChart(
                           LineChartData(
                             gridData: const FlGridData(show: false),
                             borderData: FlBorderData(show: false),
                             lineBarsData: [
                               LineChartBarData(
                                 spots: weightSpots,
                                 isCurved: true,
                                 color: theme.colorScheme.primary,
                                 barWidth: 3,
                                 dotData: const FlDotData(show: false),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Text('Daily Mortality Trend', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                       const SizedBox(height: 16),
                       SizedBox(
                         height: 250,
                         child: BarChart(
                           BarChartData(
                             gridData: const FlGridData(show: false),
                             borderData: FlBorderData(show: false),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Text('Revenue vs Expenses', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                       const SizedBox(height: 16),
                       SizedBox(
                         height: 250,
                         child: financeSpotsRev.isEmpty ? const Center(child: Text('No data')) : LineChart(
                           LineChartData(
                             gridData: const FlGridData(show: false),
                             borderData: FlBorderData(show: false),
                             titlesData: const FlTitlesData(
                               rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                               topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                             ),
                             lineBarsData: [
                               LineChartBarData(
                                 spots: financeSpotsRev,
                                 isCurved: true,
                                 color: theme.colorScheme.primary,
                                 barWidth: 3,
                                 belowBarData: BarAreaData(show: true, color: theme.colorScheme.primary.withValues(alpha: 0.1)),
                               ),
                               LineChartBarData(
                                 spots: financeSpotsExp,
                                 isCurved: true,
                                 color: theme.colorScheme.error,
                                 barWidth: 3,
                                 belowBarData: BarAreaData(show: true, color: theme.colorScheme.error.withValues(alpha: 0.1)),
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

  Widget _buildStatCard(BuildContext context, String title, String value) {
    return CustomCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: Text(title, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)), maxLines: 1)),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

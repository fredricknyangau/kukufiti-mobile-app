import 'package:mobile/presentation/widgets/custom_divider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:fl_chart/fl_chart.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/custom_card.dart';

import '../../../providers/data_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final metricsAsync = ref.watch(dashboardMetricsProvider);
    final profileAsync = ref.watch(profileProvider);
    final alertsAsync = ref.watch(alertsProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardMetricsProvider);
          ref.invalidate(profileProvider);
          ref.invalidate(alertsProvider);
        },
        child: metricsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (metrics) {
            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                _buildAppBar(context, ref, profileAsync),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildCriticalAlertsHeader(context, alertsAsync, theme),
                        const SizedBox(height: 16),
                        _buildFinancialSummary(context, ref, theme, metrics),
                        const SizedBox(height: 24),
                        _buildSectionTitle(theme, 'Quick Overview'),
                        const SizedBox(height: 12),
                        _buildStatsGrid(context, metrics),
                        const SizedBox(height: 24),
                        _buildSectionTitle(theme, 'Quick Actions'),
                        const SizedBox(height: 12),
                        _buildQuickActions(context),
                        const SizedBox(height: 24),
                        _buildSectionTitle(theme, 'Live Tracking Timeline'),
                        const SizedBox(height: 12),
                        _buildActivitiesTimeline(context, theme),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<Map<String, dynamic>> profileAsync,
  ) {
    final theme = Theme.of(context);
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      backgroundColor: theme.colorScheme.primary,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
        title: Text(
          'Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withValues(alpha: 0.8),
                theme.colorScheme.primary.withValues(alpha: 0.6),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(
                  LucideIcons.leaf,
                  size: 160,
                  color: theme.colorScheme.onPrimary.withValues(alpha: 0.08),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back!',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary.withValues(
                          alpha: 0.8,
                        ),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    profileAsync.maybeWhen(
                      data: (p) => Text(
                        p['full_name'] ?? 'Farmer',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      orElse: () => Text(
                        'Farmer',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(LucideIcons.logOut, color: theme.colorScheme.onPrimary),
          onPressed: () => ref.read(authProvider.notifier).logout(),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildFinancialSummary(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    Map<String, dynamic> metrics,
  ) {
    final totalRev = (metrics['total_revenue'] as num?)?.toDouble() ?? 0.0;
    final totalExp = (metrics['total_expenses'] as num?)?.toDouble() ?? 0.0;
    final netProfit = (metrics['net_profit'] as num?)?.toDouble() ?? 0.0;

    final chartAsync = ref.watch(financialChartProvider);

    return CustomCard(
      isPremium: true,
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surface.withValues(alpha: 0.95),
            ],
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Net Earnings',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      NumberFormat.currency(
                        locale: 'en_KE',
                        symbol: 'KES ',
                      ).format(netProfit),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: netProfit >= 0
                            ? theme.colorScheme.primary
                            : theme.colorScheme.error,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        (netProfit >= 0
                                ? theme.colorScheme.primary
                                : theme.colorScheme.error)
                            .withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    netProfit >= 0
                        ? LucideIcons.trendingUp
                        : LucideIcons.trendingDown,
                    color: netProfit >= 0
                        ? theme.colorScheme.primary
                        : theme.colorScheme.error,
                    size: 28,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Mini Graph section
            SizedBox(
              height: 60,
              width: double.infinity,
              child: chartAsync.when(
                loading: () => const Center(
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                error: (e, _) => const SizedBox.shrink(),
                data: (chartData) {
                  if (chartData.isEmpty) return const SizedBox.shrink();

                  final List<FlSpot> revSpots = [];
                  final List<FlSpot> expSpots = [];

                  final sortedData = List<dynamic>.from(chartData)
                    ..sort(
                      (a, b) => (a['date'] ?? '').compareTo(b['date'] ?? ''),
                    );

                  for (int i = 0; i < sortedData.length; i++) {
                    final d = sortedData[i];
                    revSpots.add(
                      FlSpot(
                        i.toDouble(),
                        (d['revenue'] as num?)?.toDouble() ?? 0.0,
                      ),
                    );
                    expSpots.add(
                      FlSpot(
                        i.toDouble(),
                        (d['expenses'] as num?)?.toDouble() ?? 0.0,
                      ),
                    );
                  }

                  return LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: revSpots,
                          isCurved: true,
                          color: theme.colorScheme.primary,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.08,
                            ),
                          ),
                        ),
                        LineChartBarData(
                          spots: expSpots,
                          isCurved: true,
                          color: theme.colorScheme.error,
                          barWidth: 2,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          dashArray: [5, 5],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: CustomDivider(height: 1),
            ),
            Row(
              children: [
                Expanded(
                  child: _buildFinancialMetric(
                    theme,
                    title: 'Revenue',
                    amount: totalRev,
                    color: theme.colorScheme.primary,
                    icon: LucideIcons.arrowUpRight,
                  ),
                ),
                Container(
                  height: 30,
                  width: 1,
                  color: theme.colorScheme.outline.withValues(alpha: 0.5),
                ),
                Expanded(
                  child: _buildFinancialMetric(
                    theme,
                    title: 'Expenses',
                    amount: totalExp,
                    color: theme.colorScheme.error,
                    icon: LucideIcons.arrowDownLeft,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialMetric(
    ThemeData theme, {
    required String title,
    required double amount,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          NumberFormat.compactCurrency(
            locale: 'en_KE',
            symbol: 'KES ',
          ).format(amount),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context, Map<String, dynamic> metrics) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(
          context,
          title: 'Active Batches',
          value: (metrics['active_flocks'] ?? 0).toString(),
          icon: LucideIcons.layers,
          color: Colors.blue,
          onTap: () => context.push('/batches'),
        ),
        _buildStatCard(
          context,
          title: 'Total Birds',
          value: (metrics['current_birds'] ?? 0).toString(),
          icon: LucideIcons.userPlus, // Changed to general user/bird count icon
          color: Colors.orange,
          onTap: () => context.push('/batches'),
        ),
        _buildStatCard(
          context,
          title: 'Mortality Rate',
          value: '${metrics['mortality_rate'] ?? 0}%',
          icon: LucideIcons.skull,
          color: Colors.redAccent,
          onTap: () => context.push('/mortality'),
        ),
        _buildStatCard(
          context,
          title: 'Market Prices',
          value: 'Check',
          icon: LucideIcons.lineChart,
          color: Colors.green,
          onTap: () => context.push('/market'),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return CustomCard(
      isPremium: true,
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          Positioned(
            bottom: -4,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 25,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        const FlSpot(0, 1),
                        const FlSpot(1, 1.3),
                        const FlSpot(2, 1.1),
                        const FlSpot(3, 1.6),
                        const FlSpot(4, 1.5),
                        const FlSpot(5, 1.8),
                      ],
                      isCurved: true,
                      color: color.withValues(alpha: 0.4),
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 24, color: color),
              ),
              const Spacer(),
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildActionItem(
            context,
            icon: LucideIcons.users,
            label: 'People',
            route: '/people',
            color: Colors.blueGrey,
          ),
          _buildActionItem(
            context,
            icon: LucideIcons.shoppingBag,
            label: 'Market',
            route: '/market',
            color: Colors.teal,
          ),
          _buildActionItem(
            context,
            icon: LucideIcons.package,
            label: 'Inventory',
            route: '/inventory',
            color: Colors.indigo,
          ),
          _buildActionItem(
            context,
            icon: LucideIcons.heartPulse,
            label: 'Vet',
            route: '/vet',
            color: Colors.redAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () => context.push(route),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: color.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildCriticalAlertsHeader(BuildContext context, AsyncValue<List<dynamic>> alertsAsync, ThemeData theme) {
    return alertsAsync.maybeWhen(
      data: (alerts) {
        final criticals = alerts.where((a) => a['severity'] == 'critical').toList();
        if (criticals.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.colorScheme.error, theme.colorScheme.error.withValues(alpha: 0.8)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.error.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            children: [
              const Icon(LucideIcons.shieldAlert, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Critical Attention Required',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${criticals.length} issues need immediate resolution.',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(LucideIcons.chevronRight, color: Colors.white, size: 20),
            ],
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _buildActivitiesTimeline(BuildContext context, ThemeData theme) {
    final activities = [
      {'title': 'Mortality Recorded', 'desc': 'Batch 3 - 2 birds', 'time': '10 m ago', 'icon': LucideIcons.skull, 'color': Colors.redAccent},
      {'title': 'Feed Replenished', 'desc': 'added 50kg Starter', 'time': '2 h ago', 'icon': LucideIcons.package, 'color': Colors.blue},
      {'title': 'Weight Check', 'desc': 'Batch 2 avg 1.45kg', 'time': 'Yesterday', 'icon': LucideIcons.scale, 'color': Colors.amber},
    ];

    return Column(
      children: activities.map((act) {
        final Color color = act['color'] as Color;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(act['icon'] as IconData, color: color, size: 16),
                  ),
                  Container(
                    width: 2,
                    height: 28,
                    color: theme.colorScheme.outline.withValues(alpha: 0.4),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomCard(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              act['title'].toString(),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              act['desc'].toString(),
                              style: TextStyle(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        act['time'].toString(),
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

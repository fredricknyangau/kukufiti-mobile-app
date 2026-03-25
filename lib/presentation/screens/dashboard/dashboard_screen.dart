import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:mobile/presentation/widgets/custom_divider.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../core/network/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:fl_chart/fl_chart.dart';

import '../../../providers/auth_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/custom_card.dart';

import '../../../providers/update_provider.dart';
import '../../widgets/update_dialog.dart';

import '../../../providers/data_providers.dart';
import '../../widgets/premium_upgrade_dialog.dart';
import '../../../core/models/broiler_models.dart';
import '../../../core/services/sync_service.dart';
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _updateChecked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUpdate();
      SyncService.startAutoSync(context);
    });
  }

  Future<void> _checkForUpdate() async {
    if (_updateChecked) return;
    _updateChecked = true;

    final updateInfo = await ref.read(updateCheckProvider.future);

    if (!mounted) return;

    if (updateInfo != null && updateInfo.isUpdateAvailable) {
      showDialog(
        context: context,
        barrierDismissible: false, // force user to acknowledge
        builder: (_) => UpdateDialog(updateInfo: updateInfo),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        _buildCriticalAlertsHeader(context, alertsAsync, theme)
                            .animate()
                            .fadeIn(duration: 600.ms)
                            .slideY(begin: 0.2, end: 0),
                        const SizedBox(height: 16),
                        _buildFinancialSummary(context, ref, theme, metrics)
                            .animate()
                            .fadeIn(delay: 100.ms)
                            .slideY(begin: 0.1, end: 0),
                        const SizedBox(height: 20),
                        _buildFarmsSummary(context, theme)
                            .animate()
                            .fadeIn(delay: 200.ms),
                        _buildTasksOverview(context, theme)
                            .animate()
                            .fadeIn(delay: 300.ms),
                        const SizedBox(height: 24),
                        _buildSectionTitle(theme, 'Quick Overview')
                            .animate()
                            .fadeIn(delay: 400.ms),
                        const SizedBox(height: 12),
                        _buildStatsGrid(context, metrics),
                        const SizedBox(height: 24),
                        _buildSectionTitle(theme, 'Quick Actions'),

                        const SizedBox(height: 12),
                        _buildQuickActions(context),
                        const SizedBox(height: 24),
                        _buildSectionTitle(theme, 'Live Tracking Timeline'),
                        const SizedBox(height: 12),
                        _buildActivitiesTimeline(context, theme, metrics),
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
    AsyncValue<User> profileAsync,
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
                padding: const EdgeInsets.only(left: 56, top: 40),
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
                        p.fullName ?? 'Farmer',
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
    final subAsync = ref.watch(subscriptionProvider);
    final plan = subAsync.value?['plan_type'] ?? 'STARTER';
    final isPremium = plan != 'STARTER';

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
        child: Stack(
          children: [
            Column(
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
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      if (!isPremium) {
                        showPremiumUpgradeDialog(context, 'PDF Export');
                      } else {
                        _generateAndSharePdf(context, metrics);
                      }
                    },
                    icon: Icon(
                      isPremium ? LucideIcons.download : LucideIcons.lock,
                      size: 16,
                    ),
                    label: const Text(
                      'Export PDF Report',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            if (!isPremium)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.1),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(alpha: 0.9),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(LucideIcons.lock, color: Colors.white, size: 24),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Premium Feature',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            TextButton(
                              onPressed: () => showPremiumUpgradeDialog(context, 'Financial Trend Analytics'),
                              child: const Text('Upgrade to View', style: TextStyle(color: Colors.white, decoration: TextDecoration.underline)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
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
    final subAsync = ref.watch(subscriptionProvider);
    final plan = subAsync.value?['plan_type'] ?? 'STARTER';
    final isPremium = plan != 'STARTER';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GridView.count(
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
              icon: LucideIcons.userPlus,
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
        ),
        const SizedBox(height: 16),
        CustomCard(
          isPremium: isPremium,
          onTap: () {
            if (!isPremium) {
              // import 'premium_upgrade_dialog.dart' will be added in next step at top if missing.
              // Assuming showPremiumUpgradeDialog exists
              showPremiumUpgradeDialog(context, 'FCR Analytics');
            } else {
              context.push('/analytics');
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.compass, color: Colors.deepPurple),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Feed Conversion Ratio (FCR)', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        isPremium 
                            ? 'Your aggregate FCR is ${metrics['fcr_rate'] ?? '0.0'}'
                            : 'Unlock advanced metric analytics calculation',
                        style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                      ),
                    ],
                  ),
                ),
                if (!isPremium)
                  const Icon(LucideIcons.lock, size: 16, color: Colors.grey)
                else
                  const Icon(LucideIcons.chevronRight, color: Colors.grey),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (isPremium)
          _buildClimateCard(context, Theme.of(context))
        else
          _buildLockedClimateCard(context, Theme.of(context)),
      ],
    );
  }

  Widget _buildClimateCard(BuildContext context, ThemeData theme) {
    return CustomCard(
      isPremium: true,
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Smart Climate (IoT)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Demo', style: TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildClimateMetric(theme, icon: LucideIcons.thermometer, label: 'Temp', value: '— °C', color: Colors.orange)),
                Container(height: 30, width: 1, color: theme.colorScheme.outline.withValues(alpha: 0.3)),
                Expanded(child: _buildClimateMetric(theme, icon: LucideIcons.droplet, label: 'Humidity', value: '—%', color: Colors.blue)),
                Container(height: 30, width: 1, color: theme.colorScheme.outline.withValues(alpha: 0.3)),
                Expanded(child: _buildClimateMetric(theme, icon: LucideIcons.wifi, label: 'Sensor', value: 'None', color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '🔌 Connect an IoT sensor to see live climate data.',
              style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.5), fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClimateMetric(ThemeData theme, {required IconData icon, required String label, required String value, required Color color}) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        Text(label, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
      ],
    );
  }

  Widget _buildLockedClimateCard(BuildContext context, ThemeData theme) {
    return CustomCard(
      isPremium: false,
      onTap: () => showPremiumUpgradeDialog(context, 'Smart IoT Climate Trackers'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.teal.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(LucideIcons.gauge, color: Colors.teal),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Smart Climate Trackers (IoT)', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Unlock real-time sensor analytics integration', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                ],
              ),
            ),
            const Icon(LucideIcons.lock, size: 16, color: Colors.grey),
          ],
        ),
      ),
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
    ).animate().scale(delay: (200).ms, duration: 400.ms, curve: Curves.easeOutBack);
  }



  Widget _buildQuickActions(BuildContext context) {
    final subAsync = ref.watch(subscriptionProvider);
    final plan = subAsync.value?['plan_type'] ?? 'STARTER';
    final isStarter = plan == 'STARTER';

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildActionItem(
            context,
            icon: LucideIcons.sparkles,
            label: 'AI Advisory',
            route: '/ai-insights-hub',
            color: Colors.deepPurple,
          ),
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
            isLocked: isStarter,
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
    bool isLocked = false,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () {
          if (isLocked) {
            showPremiumUpgradeDialog(context, label);
          } else {
            context.push(route);
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
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
                if (isLocked)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Icon(
                        LucideIcons.lock,
                        size: 14,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isLocked ? '$label 🔒' : label,
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

  Widget _buildActivitiesTimeline(BuildContext context, ThemeData theme, Map<String, dynamic> metrics) {
    final List<dynamic> activities = metrics['recent_activities'] ?? [];

    if (activities.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text(
            'No recent activities recorded today.',
            style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
          ),
        ),
      );
    }

    return Column(
      children: activities.map((act) {
        final type = act['type'] ?? 'other';
        IconData icon = LucideIcons.bell;
        Color color = Colors.grey;

        switch (type) {
          case 'sale':
            icon = LucideIcons.shoppingBag;
            color = Colors.green;
            break;
          case 'expense':
            icon = LucideIcons.package;
            color = Colors.blue;
            break;
          case 'mortality':
            icon = LucideIcons.skull;
            color = Colors.redAccent;
            break;
          case 'feed':
            icon = LucideIcons.wheat;
            color = Colors.orange;
            break;
        }

        final dateStr = act['date'] ?? '';
        String formattedTime = 'Recent';
        try {
          final dt = DateTime.parse(dateStr);
          formattedTime = DateFormat('MMM d').format(dt);
        } catch (_) {}

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
                    child: Icon(icon, color: color, size: 16),
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
                              act['title']?.toString() ?? 'Activity',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              act['desc']?.toString() ?? '',
                              style: TextStyle(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        formattedTime,
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

  Widget _buildFarmsSummary(BuildContext context, ThemeData theme) {
    return ref.watch(farmsProvider).when(
          loading: () => const SizedBox.shrink(),
          error: (e, _) => const SizedBox.shrink(),
          data: (farms) {
            if (farms.isEmpty) {
              return Padding(
                padding: const EdgeInsets.only(top: 24),
                child: CustomCard(
                  isPremium: true,
                  onTap: () => context.push('/farms'),
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          LucideIcons.compass,
                          color: Colors.orange,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Get Started: Create a Farm',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Create your first farm location to start managing flocks and tracking analytics.',
                              style: TextStyle(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        LucideIcons.chevronRight,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                      ),
                    ],
                  ),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.only(top: 24),
              child: CustomCard(
                isPremium: true,
                onTap: () => context.push('/farms'),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        LucideIcons.home,
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Connected Farms',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'You are managing ${farms.length} locations.',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      LucideIcons.chevronRight,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                  ],
                ),
              ),
            );
          },
        );
  }

  Widget _buildTasksOverview(BuildContext context, ThemeData theme) {
    return ref.watch(tasksProvider).when(
          loading: () => const SizedBox.shrink(),
          error: (e, _) => const SizedBox.shrink(),
          data: (tasks) {
            final pendingTasks = tasks.where((t) => t['status'] == 'PENDING').toList();
            if (pendingTasks.isEmpty) return const SizedBox.shrink();

            // Trigger one-time instant ambient notification
            WidgetsBinding.instance.addPostFrameCallback((_) {
               NotificationService.showNotification(
                  id: 100,
                  title: 'Daily Reminders 🐔',
                  body: 'You have ${pendingTasks.length} pending operations today.',
               );
            });

            return Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(theme, 'Pending Tasks'),
                  const SizedBox(height: 12),
                  ...pendingTasks.take(3).map((task) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: CustomCard(
                          onTap: () => context.push('/calendar'),
                          child: ListTile(
                            dense: true,
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(LucideIcons.calendarCheck2, size: 16, color: theme.colorScheme.primary),
                            ),
                            title: Text(
                              task['title']?.toString() ?? 'Task',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(task['due_date']?.toString() ?? ''),
                            trailing: Checkbox(
                              value: false,
                              onChanged: (v) async {
                                if (v == true) {
                                  final messenger = ScaffoldMessenger.of(context);
                                  try {
                                    await ApiClient.instance.put('/tasks/${task['id']}', data: {'status': 'DONE'});
                                    ref.invalidate(tasksProvider);
                                  } catch (e) {
                                    messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
                                  }
                                }
                              },
                            ),
                          ),
                        ),
                      )),
                ],
              ),
            );
          },
        );
  }

  Future<void> _generateAndSharePdf(BuildContext context, Map<String, dynamic> metrics) async {
    final pdf = pw.Document();
    
    final totalRev = (metrics['total_revenue'] as num?)?.toDouble() ?? 0.0;
    final totalExp = (metrics['total_expenses'] as num?)?.toDouble() ?? 0.0;
    final netProfit = (metrics['net_profit'] as num?)?.toDouble() ?? 0.0;

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(level: 0, child: pw.Text('Kuku Fiti - Financial Report', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 24))),
              pw.SizedBox(height: 20),
              pw.Text('Date: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}'),
              pw.SizedBox(height: 40),
              pw.Text('Financial Overview', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
              pw.Divider(),
              pw.SizedBox(height: 12),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Total Revenue:'),
                  pw.Text('KES ${totalRev.toStringAsFixed(2)}'),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Total Expenses:'),
                  pw.Text('KES ${totalExp.toStringAsFixed(2)}'),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Divider(),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Net Earnings:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('KES ${netProfit.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'financial_report.pdf');
  }
}

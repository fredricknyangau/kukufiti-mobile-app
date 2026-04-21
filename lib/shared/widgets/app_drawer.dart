import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:mobile/shared/providers/data_providers.dart';
import 'package:mobile/core/models/broiler_models.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userAsync = ref.watch(profileProvider);
    final subscriptionAsync = ref.watch(subscriptionProvider);
    final User? user = userAsync.value;
    final currentRoute = GoRouterState.of(context).matchedLocation;
    final sub = subscriptionAsync.value;
    final plan = sub?['plan_type'] ?? 'STARTER';

    String? getRequiredPlan(String route) {
      if (['/audit-logs', '/farms', '/admin'].contains(route)) return 'ENTERPRISE';
      if ([
        '/inventory', '/alerts', '/analytics', '/reports', '/market', '/vet', 
        '/biosecurity', '/calendar', '/ai-insights-hub', '/daily-checks', '/tasks'
      ].contains(route)) {
        return 'PROFESSIONAL';
      }
      return null;
    }

    bool hasAccess(String route) {
      if (user?.isAdmin == true) return true;
      final required = getRequiredPlan(route);
      if (required == null) return true;
      if (plan == 'ENTERPRISE') return true;
      if (plan == 'PROFESSIONAL' && required == 'PROFESSIONAL') return true;
      return false;
    }

    void showUpgradeDialog(BuildContext context, String feature) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Unlock $feature', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Text('Access into $feature requires a Professional Plan subscription to enable Advanced Farm Intelligence metrics securely.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Maybe Later')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.push('/pricing');
              },
              child: const Text('Upgrade Now'),
            ),
          ],
        ),
      );
    }

    Widget buildDrawerItem(String title, String route, IconData icon) {
      final isSelected = currentRoute == route;
      final requiredPlan = getRequiredPlan(route);
      final locked = !hasAccess(route);

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        child: ListTile(
          dense: true,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          leading: Icon(
            icon,
            size: 20,
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.9),
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
            ),
          ),
          trailing: locked 
              ? Icon(
                  requiredPlan == 'ENTERPRISE' ? LucideIcons.gem : LucideIcons.lock, 
                  size: 14, 
                  color: requiredPlan == 'ENTERPRISE' ? Colors.purple.withValues(alpha: 0.6) : theme.colorScheme.onSurface.withValues(alpha: 0.4)
                ) 
              : null,
          selected: isSelected,
          selectedTileColor: theme.colorScheme.primary.withValues(alpha: 0.08),
          onTap: () {
            Navigator.pop(context);
            if (locked) {
              showUpgradeDialog(context, title + (requiredPlan == 'ENTERPRISE' ? ' (Enterprise)' : ' (Professional)'));
              return;
            }
            const branchRoutes = ['/dashboard', '/batches', '/analytics', '/settings', '/farms'];
            if (branchRoutes.contains(route)) {
              context.go(route);
            } else {
              context.push(route);
            }
          },
        ),
      );
    }

    Widget buildCategory(
      String title,
      List<Widget> children, {
      bool initiallyExpanded = false,
      IconData? icon,
    }) {
      return Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          dense: true,
          leading: icon != null
              ? Icon(
                  icon,
                  size: 20,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                )
              : null,
          title: Text(
            title,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              fontSize: 11,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          initiallyExpanded: initiallyExpanded,
          childrenPadding: EdgeInsets.zero,
          children: [...children, const SizedBox(height: 4)],
        ),
      );
    }

    return Drawer(
      backgroundColor: theme.colorScheme.surface,
      elevation: 0,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                    width: 1,
                  ),
                ),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Soft glowing fluid circles in header
                  Positioned(
                    top: -40,
                    right: -40,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Icon(
                          LucideIcons.feather,
                          color: theme.colorScheme.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'KukuFiti',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.7,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Farm Intelligence',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  buildCategory(
                    'CORE OPERATIONS',
                    [
                      buildDrawerItem('Dashboard', '/dashboard', LucideIcons.layoutDashboard),
                      buildDrawerItem('Flock Management', '/batches', LucideIcons.package),
                      buildDrawerItem('Mortality', '/mortality', LucideIcons.skull),
                      buildDrawerItem('Feed', '/feed', LucideIcons.wheat),
                      buildDrawerItem('Weight', '/weight', LucideIcons.scale),
                      buildDrawerItem('Vaccinations', '/vaccinations', LucideIcons.syringe),
                      buildDrawerItem('AI Advisory', '/ai-insights-hub', LucideIcons.sparkles),
                      buildDrawerItem('Daily Checks', '/daily-checks', LucideIcons.clipboardList),
                    ],
                    icon: LucideIcons.activity,
                    initiallyExpanded: [
                      '/dashboard',
                      '/batches',
                      '/mortality',
                      '/feed',
                      '/weight',
                      '/vaccinations',
                    ].contains(currentRoute),
                  ),
                  buildCategory(
                    'FINANCIALS',
                    [
                      buildDrawerItem('Expenses', '/expenditures', LucideIcons.wallet),
                      buildDrawerItem('Sales', '/sales', LucideIcons.shoppingCart),
                      buildDrawerItem('Market', '/market', LucideIcons.dollarSign),
                      buildDrawerItem('Analytics', '/analytics', LucideIcons.barChart3),
                    ],
                    icon: LucideIcons.banknote,
                    initiallyExpanded: ['/expenditures', '/sales', '/market', '/analytics'].contains(currentRoute),
                  ),
                  buildCategory(
                    'BUSINESS',
                    [
                      buildDrawerItem('People', '/people', LucideIcons.users),
                      buildDrawerItem('Calendar', '/calendar', LucideIcons.calendar),
                      buildDrawerItem('Tasks', '/tasks', LucideIcons.checkSquare),
                      buildDrawerItem('Inventory', '/inventory', LucideIcons.archive),
                      buildDrawerItem('Biosecurity', '/biosecurity', LucideIcons.clipboardCheck),
                      buildDrawerItem('Reports', '/reports', LucideIcons.fileText),
                      buildDrawerItem('Vet & Health', '/vet', LucideIcons.activity),
                      buildDrawerItem('Resources', '/resources', LucideIcons.bookOpen),
                      if (plan == 'ENTERPRISE')
                        buildDrawerItem('Manage Farms', '/farms', LucideIcons.home),
                      buildDrawerItem('Settings', '/settings', LucideIcons.settings),
                      buildDrawerItem('Alerts', '/alerts', LucideIcons.bell),
                    ],
                    icon: LucideIcons.briefcase,
                    initiallyExpanded: [
                      '/people',
                      '/calendar',
                      '/inventory',
                      '/biosecurity',
                      '/reports',
                      '/vet',
                      '/resources',
                      '/settings',
                      '/alerts',
                    ].contains(currentRoute),
                  ),
                  if (user != null && (user.isSuperuser == true || user.role == 'ADMIN'))
                    buildCategory(
                      'ADMIN LINKS',
                      [
                        buildDrawerItem('Admin Dashboard', '/admin', LucideIcons.shield),
                        buildDrawerItem('Audit Logs', '/audit-logs', LucideIcons.clipboardCheck),
                      ],
                      icon: LucideIcons.lock,
                      initiallyExpanded: ['/admin', '/audit-logs'].contains(currentRoute),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.only(left: 8, right: 4),
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                      radius: 18,
                      child: Text(
                        (user?.fullName ?? 'F')[0].toUpperCase(),
                        style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            user?.fullName ?? 'Farmer',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        subscriptionAsync.when(
                          data: (sub) {
                            final plan = sub['plan_type'] ?? 'STARTER';
                            final isPremium = plan != 'STARTER';
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isPremium 
                                    ? theme.colorScheme.primary.withValues(alpha: 0.1) 
                                    : theme.colorScheme.onSurface.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isPremium 
                                      ? theme.colorScheme.primary.withValues(alpha: 0.3) 
                                      : theme.colorScheme.onSurface.withValues(alpha: 0.1),
                                ),
                              ),
                              child: Text(
                                plan,
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                  color: isPremium ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            );
                          },
                          loading: () => const SizedBox.shrink(),
                          error: (e, s) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                    subtitle: Text(user?.email ?? '', style: const TextStyle(fontSize: 10)),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/profile');
                    },
                  ),
                  ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.only(left: 8, right: 4),
                    leading: Icon(LucideIcons.trendingUp, color: theme.colorScheme.primary, size: 20),
                    title: Text(
                      'Upgrade Plan',
                      style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/pricing');
                    },
                  ),
                  ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.only(left: 8, right: 4),
                    leading: Icon(LucideIcons.logOut, color: theme.colorScheme.error, size: 20),
                    title: Text(
                      'Logout',
                      style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    onTap: () => ref.read(authProvider.notifier).logout(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

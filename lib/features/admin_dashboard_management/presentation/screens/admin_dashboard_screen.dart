import 'package:mobile/presentation/widgets/custom_divider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';


import '../../../../presentation/widgets/custom_card.dart';
import '../../../../providers/data_providers.dart';

import '../../../../core/utils/error_handler.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final statsAsync = ref.watch(adminStatsProvider);
    final transAsync = ref.watch(adminTransactionsProvider);

    if (statsAsync.isLoading || transAsync.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (statsAsync.hasError || transAsync.hasError) {
      final error = statsAsync.error ?? transAsync.error;
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
                const SizedBox(height: 16),
                Text(
                  getFriendlyErrorMessage(error),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () {
                    ref.invalidate(adminStatsProvider);
                    ref.invalidate(adminTransactionsProvider);
                  },
                  icon: const Icon(LucideIcons.refreshCw, size: 16),
                  label: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final stats = statsAsync.value ?? {};
    final transactions = transAsync.value ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw),
            onPressed: () {
               ref.invalidate(adminStatsProvider);
               ref.invalidate(adminTransactionsProvider);
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.2,
              children: [
                _buildStatCard(context, 'Total Users', '${stats['total_users'] ?? 0}', '${stats['active_users'] ?? 0} active', LucideIcons.userPlus),
                _buildStatCard(context, 'Inventory', '${stats['total_flocks'] ?? 0} Flocks', '${stats['active_flocks'] ?? 0} active', LucideIcons.fileText),
                _buildStatCard(context, 'Active Subs', '${stats['active_subscriptions'] ?? 0}', '', LucideIcons.creditCard),
                _buildStatCard(
                  context, 
                  'Est. Revenue', 
                  NumberFormat.compactCurrency(locale: 'en_KE', symbol: 'KES ').format(double.tryParse(stats['total_revenue_est']?.toString() ?? '') ?? 0.0), 
                  'Lifelong Estimate', 
                  LucideIcons.banknote
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Recent Transactions', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (transactions.isEmpty)
               CustomCard(
                 child: Center(
                   child: Padding(
                     padding: const EdgeInsets.all(24.0),
                     child: Text(
                       'No recent transactions.',
                       style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                     ),
                   ),
                 ),
               )
            else
               CustomCard(
                 padding: EdgeInsets.zero,
                 child: ListView.separated(
                   shrinkWrap: true,
                   physics: const NeverScrollableScrollPhysics(),
                   itemCount: transactions.length,
                   separatorBuilder: (c, i) => const CustomDivider(height: 1),
                   itemBuilder: (context, index) {
                     final trx = transactions[index];
                     final status = trx['status']?.toString().toUpperCase() ?? 'UNKNOWN';
                     final isCompleted = status == 'COMPLETED' || status == 'SUCCESS' || status == 'ACTIVE';
                     return ListTile(
                       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                       leading: CircleAvatar(
                         backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                         child: Icon(LucideIcons.user, color: theme.colorScheme.primary),
                       ),
                       title: Text(trx['user_email'] ?? 'Unknown User', style: const TextStyle(fontWeight: FontWeight.bold)),
                       subtitle: Text('${trx['plan'] ?? 'Base Plan'} • KES ${trx['amount'] ?? 0}'),
                       trailing: Chip(
                         label: Text(status),
                         backgroundColor: isCompleted ? Colors.green : Colors.orange,
                         labelStyle: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                       ),
                     );
                   },
                  ),
                ),
                const SizedBox(height: 24),
                Text('Management Controls', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                CustomCard(
                  padding: EdgeInsets.zero,
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(LucideIcons.bookOpen, color: theme.colorScheme.primary),
                    ),
                    title: const Text('Manage Guides & Resources', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Add, edit, or delete farm resources', style: TextStyle(fontSize: 12)),
                    trailing: const Icon(LucideIcons.chevronRight),
                    onTap: () => GoRouter.of(context).push('/manage-resources'),
                  ),
                ),
                const SizedBox(height: 12),
                CustomCard(
                  padding: EdgeInsets.zero,
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(LucideIcons.users, color: theme.colorScheme.primary),
                    ),
                    title: const Text('Manage Accounts & Users', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('View and update user roles and status', style: TextStyle(fontSize: 12)),
                    trailing: const Icon(LucideIcons.chevronRight),
                    onTap: () => GoRouter.of(context).push('/manage-users'),
                  ),
                ),
          ],
        ),
      ),
    );
  }


  Widget _buildStatCard(BuildContext context, String title, String value, String subtitle, IconData icon) {
    return CustomCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              Icon(icon, size: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
          ]
        ],
      ),
    );
  }
}

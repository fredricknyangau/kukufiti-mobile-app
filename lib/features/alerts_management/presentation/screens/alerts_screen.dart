import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../presentation/widgets/app_drawer.dart';
import '../../../../presentation/widgets/custom_card.dart';
import '../../../../providers/data_providers.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/utils/toast_service.dart';

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final alertsAsync = ref.watch(alertsProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Alerts & Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: alertsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
        data: (alerts) {
          if (alerts.isEmpty) {
             return const Center(child: Text('You have no new alerts.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: alerts.length,
            itemBuilder: (context, index) {
               final alert = alerts[index];
               final severity = alert['severity']?.toString().toLowerCase() ?? 'info';
               final isError = severity == 'critical' || severity == 'error' || severity == 'high';

               return CustomCard(
                 margin: const EdgeInsets.only(bottom: 12),
                 child: ListTile(
                   leading: Icon(
                      isError ? LucideIcons.alertTriangle : LucideIcons.info, 
                      color: isError ? theme.colorScheme.error : theme.colorScheme.primary
                   ),
                   title: Text(alert['title'] ?? 'Alert', style: const TextStyle(fontWeight: FontWeight.bold)),
                   subtitle: Text(alert['message'] ?? 'Check system details.'),
                   trailing: Row(
                     mainAxisSize: MainAxisSize.min,
                     children: [
                       Text(alert['created_at'] != null ? alert['created_at'].toString().split('T').first : '', style: const TextStyle(fontSize: 12)),
                       if (alert['status'] != 'acknowledged' && alert['status'] != 'resolved') ...[
                         const SizedBox(width: 8),
                         IconButton(
                           icon: Icon(LucideIcons.checkCheck, color: theme.colorScheme.primary, size: 20),
                           tooltip: 'Acknowledge',
                           onPressed: () async {
                             try {
                               await ApiClient.instance.put('${ApiEndpoints.alerts}${alert['id']}', data: {
                                 'status': 'acknowledged',
                               });
                               ref.invalidate(alertsProvider);
                             } catch (e) {
                               if (context.mounted) ToastService.showError(context, 'Failed to update alert status');
                             }
                           },
                         ),
                       ],
                     ],
                   ),
                 ),
               );
            },
          );
        },
      ),
    );
  }
}

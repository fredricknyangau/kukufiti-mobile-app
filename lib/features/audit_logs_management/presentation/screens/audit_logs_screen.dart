import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../presentation/widgets/custom_card.dart';
import '../../../../providers/data_providers.dart';


class AuditLogsScreen extends ConsumerWidget {
  const AuditLogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final logsAsync = ref.watch(auditLogsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('System Audit Logs', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(LucideIcons.fileText), onPressed: () => _showAuditLogViewer(context, logsAsync.value ?? [])),
        ],
      ),
      body: logsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
        data: (logs) {
          if (logs.isEmpty) {
             return const Center(child: Text('No audit logs available.'));
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              final isSystem = (log['user_email']?.toString() ?? '') == 'system';
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: CustomCard(
                child: ListTile(
                   leading: CircleAvatar(
                     backgroundColor: isSystem ? theme.colorScheme.secondary.withValues(alpha: 0.1) : theme.colorScheme.primary.withValues(alpha: 0.1),
                     child: Icon(
                       isSystem ? LucideIcons.settings : LucideIcons.user,
                       color: isSystem ? theme.colorScheme.secondary : theme.colorScheme.primary,
                     ),
                   ),
                   title: Text(log['action']?.toString() ?? 'Action', style: const TextStyle(fontWeight: FontWeight.bold)),
                   subtitle: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text(log['details']?.toString() ?? 'Details'),
                       const SizedBox(height: 4),
                       Text('By: ${log['user_email'] ?? 'Unknown'}', style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                     ],
                   ),
                   trailing: Text(log['created_at'] != null ? log['created_at'].toString().split('T').first : '', style: const TextStyle(fontSize: 12)),
                )
              ));
            },
          );
        },
      ),
    );
  }

  void _showAuditLogViewer(BuildContext context, List<dynamic> logs) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Exported Audit Logs', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: logs.isEmpty
                ? const Center(child: Text('No data found.'))
                : Scrollbar(
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Timestamp', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('User Email', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Resource', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('IP Address', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Details', style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: logs.map((log) {
                            return DataRow(
                              cells: [
                                DataCell(Text(log['timestamp']?.toString() ?? '')),
                                DataCell(Text(log['action']?.toString() ?? '')),
                                DataCell(Text(log['user_email']?.toString() ?? 'System')),
                                DataCell(Text(log['resource_type']?.toString() ?? '')),
                                DataCell(Text(log['ip_address']?.toString() ?? 'N/A')),
                                DataCell(Text(log['details']?.toString() ?? '')),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../presentation/widgets/custom_card.dart';
import '../../../../providers/data_providers.dart';
import '../../../../core/network/api_client.dart';
import 'package:dio/dio.dart';

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
          IconButton(icon: const Icon(LucideIcons.fileText), onPressed: () => _showAuditLogViewer(context)),
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

  void _showAuditLogViewer(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Exported Audit Logs', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: FutureBuilder<Response>(
              future: ApiClient.instance.get(
                '/audit/export',
                options: Options(responseType: ResponseType.plain),
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                }
                final res = snapshot.data;
                if (res == null || res.data == null) {
                  return const Center(child: Text('No data found.'));
                }
                final csvText = res.data as String;
                final rows = csvText.split('\n').where((r) => r.trim().isNotEmpty).toList();
                
                if (rows.isEmpty) {
                  return const Center(child: Text('Log is empty.'));
                }

                final header = rows[0].split(',');
                final dataRows = rows.skip(1).map((r) => r.split(',')).toList();

                return Scrollbar(
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: header.map((h) => DataColumn(label: Text(h, style: const TextStyle(fontWeight: FontWeight.bold)))).toList(),
                        rows: dataRows.map((dr) {
                          return DataRow(
                            cells: dr.map((c) => DataCell(Text(c))).toList(),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                );
              },
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

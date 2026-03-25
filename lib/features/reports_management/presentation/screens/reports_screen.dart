import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../presentation/widgets/app_drawer.dart';
import '../../../../presentation/widgets/custom_card.dart';
import '../../../../presentation/widgets/premium_gate.dart';
import '../../../../core/network/api_client.dart';
import 'package:dio/dio.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Reports', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: PremiumGate(
        featureKey: 'reports',
        featureName: 'Reporting & Export',
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomCard(
              isPremium: true,
              child: ListTile(
                leading: Icon(LucideIcons.fileText, color: theme.colorScheme.primary),
                title: const Text('Batch Summary Report', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Export complete metrics for a selected batch.'),
                trailing: const Icon(LucideIcons.fileText),
                onTap: () => _showReportViewer(context, 'production'),
              ),
            ),
            const SizedBox(height: 12),
            CustomCard(
              isPremium: true,
              child: ListTile(
                leading: Icon(LucideIcons.fileBarChart, color: theme.colorScheme.secondary),
                title: const Text('Financial Report', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Monthly profit/loss statement.'),
                trailing: const Icon(LucideIcons.fileText),
                onTap: () => _showReportViewer(context, 'financial'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReportViewer(BuildContext context, String type) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${type == 'production' ? 'Production' : 'Financial'} Report', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: FutureBuilder<Response>(
              future: ApiClient.instance.get(
                '/analytics/reports/export?report_type=$type',
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
                  return const Center(child: Text('Report is empty.'));
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

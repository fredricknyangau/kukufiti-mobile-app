import 'package:mobile/presentation/widgets/custom_divider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../presentation/widgets/app_drawer.dart';
import '../../../../presentation/widgets/custom_button.dart';
import '../../../../presentation/widgets/custom_card.dart';
import '../../../../presentation/widgets/custom_input.dart';
import '../../../../core/utils/toast_service.dart';
import '../../../../providers/data_providers.dart';
import '../../../../providers/broiler_provider.dart';
import 'package:uuid/uuid.dart';

class MortalityScreen extends ConsumerWidget {
  const MortalityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final mortalityAsync = ref.watch(mortalityProvider);
    final broilerState = ref.watch(broilerProvider);
    final currentBatch = broilerState.currentBatch;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Mortality Tracking', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(mortalityProvider),
        child: mortalityAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error loading mortality: $err'),
                ElevatedButton(
                  onPressed: () => ref.invalidate(mortalityProvider),
                  child: const Text('Retry'),
                )
              ],
            ),
          ),
          data: (records) {
            final spots = <FlSpot>[];
            final now = DateTime.now();
            final labels = <String>[];
            
            for (int i = 6; i >= 0; i--) {
              final day = now.subtract(Duration(days: i));
              final dayStr = DateFormat('yyyy-MM-dd').format(day);
              labels.add(DateFormat('EEE').format(day));
              
              final countToday = records.where((e) {
                final dateStr = e['event_date']?.toString() ?? '';
                return dateStr.startsWith(dayStr);
              }).fold<int>(0, (prev, e) => prev + (e['count'] as num).toInt());
              
              spots.add(FlSpot((6 - i).toDouble(), countToday.toDouble()));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomCard(
                    isPremium: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recent Mortality Trend',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 250,
                          child: LineChart(
                            LineChartData(
                              gridData: const FlGridData(show: false),
                              titlesData: FlTitlesData(
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      final index = value.toInt();
                                      if (index >= 0 && index < labels.length) {
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: Text(labels[index], style: const TextStyle(fontSize: 10)),
                                        );
                                      }
                                      return const Text('');
                                    },
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: spots,
                                  isCurved: true,
                                  color: theme.colorScheme.error,
                                  barWidth: 4,
                                  isStrokeCapRound: true,
                                  dotData: const FlDotData(show: true),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: theme.colorScheme.error.withAlpha(50),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Recent Records',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (records.isEmpty)
                    CustomCard(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Text(
                            'No recent mortality records.',
                            style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(150)),
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: records.length,
                      itemBuilder: (context, index) {
                         final item = records.reversed.toList()[index];
                        final dateStr = item['event_date']?.toString() ?? DateTime.now().toIso8601String();
                        final date = DateTime.tryParse(dateStr) ?? DateTime.now();
                        
                        return CustomCard(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                               backgroundColor: theme.colorScheme.error.withAlpha(25),
                               child: Icon(Icons.warning, color: theme.colorScheme.error),
                            ),
                            title: Text('${item['count']} birds lost', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(DateFormat('MMM dd, yyyy - HH:mm').format(date)),
                            trailing: PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert),
                              onSelected: (value) async {
                                if (value == 'edit') {
                                  _showAddEditMortalityDialog(context, ref, currentBatch, item: item);
                                } else if (value == 'delete') {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Delete record?'),
                                      content: const Text('This action cannot be undone.'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    try {
                                      await ApiClient.instance.delete('${ApiEndpoints.mortality}/${item['id']}');
                                      ref.invalidate(mortalityProvider);
                                    } catch (e) {
                                      if (context.mounted) ToastService.showError(context, 'Failed to delete');
                                    }
                                  }
                                }
                              },
                              itemBuilder: (ctx) => const [
                                PopupMenuItem(value: 'edit', child: Text('Edit')),
                                PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                              ],
                            ),
                            onTap: () => _showMortalityDetails(context, item),
                          ),
                        );
                      },
                    ),
                ],
              ),
            );
          },
        ),
      ),
       floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditMortalityDialog(context, ref, currentBatch),
        backgroundColor: Theme.of(context).colorScheme.error,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddEditMortalityDialog(BuildContext context, WidgetRef ref, Map<String, dynamic>? currentBatch, {Map<String, dynamic>? item}) {
    showDialog(
      context: context,
      builder: (ctx) => _AddEditMortalityDialog(currentBatch: currentBatch, item: item),
    );
  }

  void _showMortalityDetails(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mortality Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('Date', item['event_date']?.toString().split('T').first ?? 'N/A'),
              _detailRow('Count', '${item['count']} birds'),
              const CustomDivider(),
              _detailRow('Cause', item['cause']?.toString().isNotEmpty == true ? item['cause'] : 'None Recorded'),
              const CustomDivider(),
              _detailRow('Symptoms', item['symptoms']?.toString().isNotEmpty == true ? item['symptoms'] : 'None Recorded'),
              const CustomDivider(),
              _detailRow('Action Taken', item['action_taken']?.toString().isNotEmpty == true ? item['action_taken'] : 'None Recorded'),
              const CustomDivider(),
              _detailRow('Notes', item['notes']?.toString().isNotEmpty == true ? item['notes'] : 'No Notes'),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

class _AddEditMortalityDialog extends StatefulWidget {
  final Map<String, dynamic>? currentBatch;
  final Map<String, dynamic>? item;

  const _AddEditMortalityDialog({this.currentBatch, this.item});

  @override
  State<_AddEditMortalityDialog> createState() => _AddEditMortalityDialogState();
}

class _AddEditMortalityDialogState extends State<_AddEditMortalityDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _countController;
  late final TextEditingController _causeController;
  late final TextEditingController _symptomsController;
  late final TextEditingController _actionController;
  late final TextEditingController _notesController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _countController = TextEditingController(text: widget.item?['count']?.toString() ?? '');
    _causeController = TextEditingController(text: widget.item?['cause'] ?? '');
    _symptomsController = TextEditingController(text: widget.item?['symptoms'] ?? '');
    _actionController = TextEditingController(text: widget.item?['action_taken'] ?? '');
    _notesController = TextEditingController(text: widget.item?['notes'] ?? '');
  }

  @override
  void dispose() {
    _countController.dispose();
    _causeController.dispose();
    _symptomsController.dispose();
    _actionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit(WidgetRef ref) async {
    if (!_formKey.currentState!.validate()) return;

    final count = int.tryParse(_countController.text) ?? 0;
    if (count <= 0) return;

    final batchId = widget.item?['flock_id'] ?? widget.currentBatch?['id'];
    if (batchId == null) {
      if (mounted) ToastService.showError(context, 'No batch selected');
      return;
    }

    setState(() => _isLoading = true);
    final payload = {
      'count': count,
      'cause': _causeController.text.trim().isEmpty ? null : _causeController.text.trim(),
      'symptoms': _symptomsController.text.trim().isEmpty ? null : _symptomsController.text.trim(),
      'action_taken': _actionController.text.trim().isEmpty ? null : _actionController.text.trim(),
      'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    };

    try {
      if (widget.item != null) {
        await ApiClient.instance.put('${ApiEndpoints.mortality}/${widget.item!['id']}', data: payload);
      } else {
        payload['event_id'] = const Uuid().v4();
        await ApiClient.instance.post('${ApiEndpoints.mortality}?flock_id=$batchId', data: payload);
      }

      if (mounted) {
        Navigator.pop(context);
        ref.invalidate(mortalityProvider);
        ToastService.showSuccess(context, 'Mortality saved successfully');
      }
    } catch (e) {
      if (mounted) ToastService.showError(context, 'Failed to save mortality');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) => AlertDialog(
        title: Text(widget.item != null ? 'Edit Mortality' : 'Log Mortality'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomInput(
                  label: 'Bird Count lost',
                  keyboardType: TextInputType.number,
                  controller: _countController,
                  validator: (v) => (int.tryParse(v ?? '') ?? 0) <= 0 ? 'Enter valid count' : null,
                ),
                const SizedBox(height: 12),
                CustomInput(label: 'Cause (Optional)', hintText: 'e.g. Illness, Heat', controller: _causeController),
                const SizedBox(height: 12),
                CustomInput(label: 'Symptoms (Optional)', hintText: 'e.g. Coughing', controller: _symptomsController),
                const SizedBox(height: 12),
                CustomInput(label: 'Action Taken (Optional)', hintText: 'e.g. Quarantined', controller: _actionController),
                const SizedBox(height: 12),
                CustomInput(label: 'Notes', controller: _notesController),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          CustomButton(text: 'Save', isLoading: _isLoading, onPressed: () => _submit(ref)),
        ],
      ),
    );
  }
}

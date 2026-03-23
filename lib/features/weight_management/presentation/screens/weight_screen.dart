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
import '../../../../core/models/broiler_models.dart';
import 'package:dio/dio.dart';

class WeightScreen extends ConsumerWidget {
  const WeightScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final weightAsync = ref.watch(weightProvider);
    final profileAsync = ref.watch(profileProvider);
    final broilerState = ref.watch(broilerProvider);
    final currentBatch = broilerState.currentBatch;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Weight Tracking', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(weightProvider),
        child: weightAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: $err'),
                ElevatedButton(onPressed: () => ref.invalidate(weightProvider), child: const Text('Retry')),
              ],
            ),
          ),
          data: (records) {
            final sortedRecords = List<WeightRecord>.from(records)
              ..sort((a, b) => a.date.compareTo(b.date));

            final spots = <FlSpot>[];
            for (int i = 0; i < sortedRecords.length; i++) {
              spots.add(FlSpot(i.toDouble(), sortedRecords[i].averageWeight));
            }

            final isViewer = profileAsync.value?.role == 'VIEWER';

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
                          'Average Weight Growth (g)',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),
                        if (spots.isEmpty)
                          const SizedBox(
                            height: 250,
                            child: Center(child: Text('No chart data')),
                          )
                        else
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
                                        if (index >= 0 && index < sortedRecords.length) {
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 8.0),
                                            child: Text(DateFormat('MMM dd').format(sortedRecords[index].date), style: const TextStyle(fontSize: 10)),
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
                                    color: theme.colorScheme.primary,
                                    barWidth: 4,
                                    isStrokeCapRound: true,
                                    dotData: const FlDotData(show: true),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      color: theme.colorScheme.primary.withAlpha(50),
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
                    'Weight Records',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (sortedRecords.isEmpty)
                    CustomCard(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Text(
                            'No weight records available.',
                            style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(150)),
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: sortedRecords.length,
                      itemBuilder: (context, index) {
                        final item = sortedRecords.reversed.toList()[index];
                        return CustomCard(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                               backgroundColor: theme.colorScheme.primary.withAlpha(25),
                               child: const Icon(Icons.fitness_center, color: Colors.blue),
                            ),
                            title: Text('${item.averageWeight} g', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(DateFormat('MMM dd, yyyy').format(item.date)),
                              trailing: isViewer ? null : PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert),
                              onSelected: (value) async {
                                if (value == 'edit') {
                                  _showAddEditWeightDialog(context, ref, currentBatch, item: item);
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
                                      await ApiClient.instance.delete('${ApiEndpoints.weight}/${item.id}');
                                      ref.invalidate(weightProvider);
                                    } catch (e) {
                                      if (context.mounted) {
                                        String message = 'Failed to delete';
                                        if (e is DioException && e.response?.statusCode == 404) {
                                          message = 'Record already deleted';
                                          ref.invalidate(weightProvider);
                                        }
                                        ToastService.showError(context, message);
                                      }
                                    }
                                  }
                                }
                              },
                              itemBuilder: (ctx) => const [
                                PopupMenuItem(value: 'edit', child: Text('Edit')),
                                PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                              ],
                            ),
                            onTap: () => _showWeightDetails(context, item),
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
       floatingActionButton: profileAsync.value?.role == 'VIEWER' ? null : FloatingActionButton(
        onPressed: () => _showAddEditWeightDialog(context, ref, currentBatch),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddEditWeightDialog(BuildContext context, WidgetRef ref, Batch? currentBatch, {WeightRecord? item}) {
    showDialog(
      context: context,
      builder: (ctx) => _AddEditWeightDialog(currentBatch: currentBatch, item: item),
    );
  }

  void _showWeightDetails(BuildContext context, WeightRecord item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Weight Measurement Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('Date', DateFormat('yyyy-MM-dd').format(item.date)),
              _detailRow('Sample Size', '${item.sampleSize} birds'),
              _detailRow('Average Weight', '${item.averageWeight} g'),
              const CustomDivider(),
              _detailRow('Notes', item.notes?.isNotEmpty == true ? item.notes! : 'No Notes'),
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

class _AddEditWeightDialog extends StatefulWidget {
  final Batch? currentBatch;
  final WeightRecord? item;

  const _AddEditWeightDialog({this.currentBatch, this.item});

  @override
  State<_AddEditWeightDialog> createState() => _AddEditWeightDialogState();
}

class _AddEditWeightDialogState extends State<_AddEditWeightDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _weightController;
  late final TextEditingController _sampleSizeController;
  late final TextEditingController _notesController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(text: widget.item?.averageWeight.toString() ?? '');
    _sampleSizeController = TextEditingController(text: widget.item?.sampleSize.toString() ?? '10');
    _notesController = TextEditingController(text: widget.item?.notes ?? '');
  }

  @override
  void dispose() {
    _weightController.dispose();
    _sampleSizeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit(WidgetRef ref) async {
    if (!_formKey.currentState!.validate()) return;

    final avgWeight = double.tryParse(_weightController.text) ?? 0.0;
    final sampleSize = int.tryParse(_sampleSizeController.text) ?? 0;

    if (avgWeight <= 0 || sampleSize <= 0) return;

    final batchId = widget.item?.batchId ?? widget.currentBatch?.id;
    if (batchId == null) {
      if (mounted) ToastService.showError(context, 'No batch selected');
      return;
    }

    setState(() => _isLoading = true);
    final payload = {
      'average_weight': avgWeight,
      'sample_size': sampleSize,
      'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      'date': widget.item?.date != null ? DateFormat('yyyy-MM-dd HH:mm:ss').format(widget.item!.date) : DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
    };

    try {
      if (widget.item != null) {
        await ApiClient.instance.put('${ApiEndpoints.weight}/${widget.item!.id}', data: payload);
      } else {
        await ApiClient.instance.post('${ApiEndpoints.weight}?batchId=$batchId', data: payload);
      }

      if (mounted) {
        Navigator.pop(context);
        ref.invalidate(weightProvider);
        ToastService.showSuccess(context, 'Weight record saved');
      }
    } catch (e) {
      if (mounted) ToastService.showError(context, 'Failed to save weight');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) => AlertDialog(
        title: Text(widget.item != null ? 'Edit Weight' : 'Log Average Weight'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomInput(
                  label: 'Sample Size (birds)',
                  keyboardType: TextInputType.number,
                  controller: _sampleSizeController,
                  validator: (v) => (int.tryParse(v ?? '') ?? 0) <= 0 ? 'Enter valid size' : null,
                ),
                const SizedBox(height: 12),
                CustomInput(
                  label: 'Average Weight (grams)',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  controller: _weightController,
                  validator: (v) => (double.tryParse(v ?? '') ?? 0.0) <= 0 ? 'Enter valid weight' : null,
                ),
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

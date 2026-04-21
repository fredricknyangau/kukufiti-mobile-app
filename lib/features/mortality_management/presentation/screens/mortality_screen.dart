import 'package:mobile/shared/widgets/custom_divider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mobile/app/theme/app_theme.dart';

import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/api_endpoints.dart';
import 'package:mobile/shared/widgets/app_drawer.dart';
import 'package:mobile/shared/widgets/custom_button.dart';
import 'package:mobile/shared/widgets/custom_card.dart';
import 'package:mobile/shared/widgets/custom_input.dart';
import 'package:mobile/core/utils/toast_service.dart';
import 'package:mobile/shared/providers/data_providers.dart';
import 'package:mobile/core/models/broiler_models.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';


class MortalityScreen extends ConsumerStatefulWidget {
  const MortalityScreen({super.key});

  @override
  ConsumerState<MortalityScreen> createState() => _MortalityScreenState();
}

class _MortalityScreenState extends ConsumerState<MortalityScreen> {
  String? _selectedBatchId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mortalityAsync = ref.watch(mortalityProvider);
    final profileAsync = ref.watch(profileProvider);
    final broilerState = ref.watch(broilerProvider);
    final currentBatch = broilerState.currentBatch;
    final canEdit = profileAsync.value?.canEdit ?? false;

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
            final filteredRecords = _selectedBatchId == null 
              ? records 
              : records.where((e) => e.batchId == _selectedBatchId).toList();
            final totalMortality = filteredRecords.fold<int>(0, (prev, e) => prev + e.count);
            final spots = <FlSpot>[];
            final now = DateTime.now();
            final labels = <String>[];
            
            for (int i = 6; i >= 0; i--) {
              final day = now.subtract(Duration(days: i));
              final dayStr = DateFormat('yyyy-MM-dd').format(day);
              labels.add(DateFormat('EEE').format(day));
              
              final countToday = filteredRecords.where((e) {
                final dateStr = DateFormat('yyyy-MM-dd').format(e.date);
                return dateStr == dayStr;
              }).fold<int>(0, (prev, e) => prev + e.count);
              
              spots.add(FlSpot((6 - i).toDouble(), countToday.toDouble()));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!canEdit)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: theme.colorScheme.secondary.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(LucideIcons.eye, size: 16, color: theme.colorScheme.secondary),
                          const SizedBox(width: 8),
                          Text(
                            'View-Only Mode',
                            style: TextStyle(
                              color: theme.colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  DropdownButtonFormField<String?>(
                    initialValue: _selectedBatchId,
                    decoration: InputDecoration(
                      labelText: 'Filter by Batch',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All Batches')),
                      ...broilerState.batches.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name))),
                    ],
                    onChanged: (v) {
                      setState(() {
                        _selectedBatchId = v;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomCard(
                    isPremium: true,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Total Mortality', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 14)),
                              const SizedBox(height: 4),
                              Text('$totalMortality birds dead', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.error)),
                            ],
                          ),
                          Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error, size: 40),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
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
                                    color: theme.colorScheme.error.withValues(alpha: 0.2),
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
                  if (filteredRecords.isEmpty)
                    CustomCard(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Text(
                            'No recent mortality records.',
                            style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredRecords.length,
                      itemBuilder: (context, index) {
                         final item = filteredRecords.reversed.toList()[index];
                        
                        return CustomCard(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                               backgroundColor: theme.colorScheme.error.withValues(alpha: 0.1),
                               child: Icon(Icons.warning, color: theme.colorScheme.error),
                            ),
                            title: Text('${item.count} birds lost', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(DateFormat('MMM dd, yyyy - HH:mm').format(item.date)),
                            trailing: !canEdit ? null : PopupMenuButton<String>(
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
                                        TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Delete', style: TextStyle(color: theme.colorScheme.error))),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    try {
                                      await ApiClient.instance.delete('${ApiEndpoints.mortality}/${item.id}');
                                      ref.invalidate(mortalityProvider);
                                    } catch (e) {
                                      if (context.mounted) {
                                        String message = 'Failed to delete';
                                        if (e is DioException && e.response?.statusCode == 404) {
                                          message = 'Record already deleted';
                                          ref.invalidate(mortalityProvider);
                                        }
                                        ToastService.showError(context, message);
                                      }
                                    }
                                  }
                                }
                              },
                              itemBuilder: (ctx) => [
                                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: theme.colorScheme.error))),
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
       floatingActionButton: canEdit ? FloatingActionButton(
        onPressed: () => _showAddEditMortalityDialog(context, ref, currentBatch),
        backgroundColor: theme.colorScheme.error,
        foregroundColor: theme.colorScheme.onError,
        child: const Icon(Icons.add),
      ) : null,
    );
  }

  void _showAddEditMortalityDialog(BuildContext context, WidgetRef ref, Batch? currentBatch, {MortalityRecord? item}) {
    showDialog(
      context: context,
      builder: (ctx) => _AddEditMortalityDialog(currentBatch: currentBatch, item: item),
    );
  }

  void _showMortalityDetails(BuildContext context, MortalityRecord item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mortality Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow(ctx, 'Date', DateFormat('yyyy-MM-dd').format(item.date)),
              _detailRow(ctx, 'Count', '${item.count} birds'),
              _detailRow(ctx, 'Type', item.type.toUpperCase()),
              const CustomDivider(),
              _detailRow(ctx, 'Cause', item.cause?.isNotEmpty == true ? item.cause! : 'None Recorded'),
              if (item.symptoms?.isNotEmpty == true) _detailRow(ctx, 'Symptoms', item.symptoms!),
              if (item.actionTaken?.isNotEmpty == true) _detailRow(ctx, 'Action Taken', item.actionTaken!),
              const CustomDivider(),
              _detailRow(ctx, 'Notes', item.notes?.isNotEmpty == true ? item.notes! : 'No Notes'),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
      ),
    );
  }

  Widget _detailRow(BuildContext context, String label, String value) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: customColors.neutral!)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

class _AddEditMortalityDialog extends StatefulWidget {
  final Batch? currentBatch;
  final MortalityRecord? item;

  const _AddEditMortalityDialog({this.currentBatch, this.item});

  @override
  State<_AddEditMortalityDialog> createState() => _AddEditMortalityDialogState();
}

class _AddEditMortalityDialogState extends State<_AddEditMortalityDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _countController;
  late final TextEditingController _causeController;
  late final TextEditingController _symptomsController;
  late final TextEditingController _actionTakenController;
  late final TextEditingController _notesController;
  String _type = 'death';

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _countController = TextEditingController(text: widget.item?.count.toString() ?? '');
    _causeController = TextEditingController(text: widget.item?.cause ?? '');
    _symptomsController = TextEditingController(text: widget.item?.symptoms ?? '');
    _actionTakenController = TextEditingController(text: widget.item?.actionTaken ?? '');
    _notesController = TextEditingController(text: widget.item?.notes ?? '');
    _type = widget.item?.type ?? 'death';
  }

  @override
  void dispose() {
    _countController.dispose();
    _causeController.dispose();
    _symptomsController.dispose();
    _actionTakenController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit(WidgetRef ref) async {
    if (!_formKey.currentState!.validate()) return;

    final count = int.tryParse(_countController.text) ?? 0;
    if (count <= 0) return;

    final batchId = widget.item?.batchId ?? widget.currentBatch?.id;
    if (batchId == null) {
      if (mounted) ToastService.showError(context, 'No batch selected');
      return;
    }

    setState(() => _isLoading = true);
    final payload = {
      'event_id': const Uuid().v4(),
      'count': count,
      'cause': _causeController.text.trim().isEmpty ? null : _causeController.text.trim(),
      'symptoms': _symptomsController.text.trim().isEmpty ? null : _symptomsController.text.trim(),
      'action_taken': _actionTakenController.text.trim().isEmpty ? null : _actionTakenController.text.trim(),
      'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    };

    try {
      if (widget.item != null) {
        await ApiClient.instance.put('${ApiEndpoints.mortality}/${widget.item!.id}', data: payload);
      } else {
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
                DropdownButtonFormField<String>(
                  initialValue: _type,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: const [
                    DropdownMenuItem(value: 'death', child: Text('Death')),
                    DropdownMenuItem(value: 'cull', child: Text('Cull')),
                  ],
                  onChanged: (v) => setState(() => _type = v!),
                ),
                const SizedBox(height: 12),
                CustomInput(label: 'Cause (Optional)', hintText: 'e.g. Illness, Heat', controller: _causeController),
                const SizedBox(height: 12),
                CustomInput(label: 'Symptoms (Optional)', hintText: 'e.g. Lethargy, cough', controller: _symptomsController),
                const SizedBox(height: 12),
                CustomInput(label: 'Action Taken (Optional)', hintText: 'e.g. Separated birds', controller: _actionTakenController),
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

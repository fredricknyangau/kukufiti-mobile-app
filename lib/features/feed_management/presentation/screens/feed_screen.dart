import 'package:mobile/presentation/widgets/custom_divider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

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
import 'package:dio/dio.dart';


class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  String? _selectedBatchId; // null = All Batches

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final feedAsync = ref.watch(feedProvider);
    final userAsync = ref.watch(profileProvider);
    final isViewer = userAsync.value?['role'] == 'VIEWER';
    final broilerState = ref.watch(broilerProvider);
    final currentBatch = broilerState.currentBatch;
    final batches = broilerState.batches;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Feed Management', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(feedProvider),
        child: feedAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: $err'),
                ElevatedButton(onPressed: () => ref.invalidate(feedProvider), child: const Text('Retry')),
              ],
            ),
          ),
          data: (records) {
             // Filter Logic
             final filteredRecords = _selectedBatchId == null 
                 ? records 
                 : records.where((e) => e['flock_id']?.toString() == _selectedBatchId).toList();

             final totalAmount = filteredRecords.fold<double>(0, (prev, e) => prev + (e['quantity_kg'] as num).toDouble());
             
             // Feed by Type Breakdown
             final feedTypes = ['starter', 'grower', 'finisher'];
             final feedByType = feedTypes.map((type) {
               final qty = filteredRecords.where((e) => e['feed_type'] == type).fold<double>(0, (prev, e) => prev + (e['quantity_kg'] as num).toDouble());
               return {'type': type, 'quantity': qty};
             }).where((e) => (e['quantity'] as double) > 0).toList();

             return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CustomCard(
                          isPremium: true,
                          child: Column(
                            children: [
                              Icon(LucideIcons.wheat, color: theme.colorScheme.primary, size: 32),
                              const SizedBox(height: 8),
                              const Text('Total Intake', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text('${totalAmount.toStringAsFixed(1)} kg'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomCard(
                          isPremium: true,
                          child: Column(
                            children: [
                              Icon(LucideIcons.list, color: theme.colorScheme.secondary, size: 32),
                              const SizedBox(height: 8),
                              const Text('Records', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text('${filteredRecords.length} Entries'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Filter Dropdown
                  DropdownButtonFormField<String?>(
                    initialValue: _selectedBatchId,
                    decoration: InputDecoration(
                      labelText: 'Filter by Batch',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All Batches')),
                      ...batches.map((b) => DropdownMenuItem(value: b['id']?.toString(), child: Text(b['name'] ?? 'Unknown'))),
                    ],
                    onChanged: (v) => setState(() => _selectedBatchId = v),
                  ),
                  
                  const SizedBox(height: 16),

                  // Feed Type Breakdown
                  if (feedByType.isNotEmpty) ...[
                    Text('Breakdown by Type', style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(150), fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: feedByType.map((t) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withAlpha(70),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: theme.colorScheme.primary.withAlpha(50)),
                        ),
                        child: Text('${(t['type'] as String).toUpperCase()}: ${(t['quantity'] as double).toStringAsFixed(1)} kg', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      )).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  const CustomDivider(),
                  const SizedBox(height: 16),

                  Text(
                    'Feed Intake Log',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (filteredRecords.isEmpty)
                    CustomCard(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Text(
                            'No feed records found for this selection.',
                            style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(150)),
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
                        final dateStr = item['event_date']?.toString() ?? DateTime.now().toIso8601String();
                        final date = DateTime.tryParse(dateStr) ?? DateTime.now();
                        
                        return CustomCard(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                               backgroundColor: theme.colorScheme.primary.withAlpha(25),
                               child: Icon(LucideIcons.wheat, color: theme.colorScheme.primary),
                            ),
                            title: Text('${item['quantity_kg']} kg - ${(item['feed_type'] ?? 'Standard').toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(DateFormat('MMM dd, yyyy').format(date)),
                            trailing: isViewer ? null : PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert),
                              onSelected: (value) async {
                                if (value == 'edit') {
                                  _showAddEditFeedDialog(context, ref, currentBatch, item: item);
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
                                      await ApiClient.instance.delete('${ApiEndpoints.feed}/${item['id']}');
                                      ref.invalidate(feedProvider);
                                    } catch (e) {
                                      if (context.mounted) {
                                        String message = 'Failed to delete';
                                        if (e is DioException && e.response?.statusCode == 404) {
                                          message = 'Record already deleted';
                                          ref.invalidate(feedProvider);
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
                            onTap: () => _showFeedDetails(context, item),
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
       floatingActionButton: isViewer ? null : FloatingActionButton(
        onPressed: () => _showAddEditFeedDialog(context, ref, currentBatch),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(LucideIcons.plus),
      ),
    );
  }

  void _showAddEditFeedDialog(BuildContext context, WidgetRef ref, Map<String, dynamic>? currentBatch, {Map<String, dynamic>? item}) {
    showDialog(
      context: context,
      builder: (ctx) => _AddEditFeedDialog(currentBatch: currentBatch, item: item),
    );
  }

  void _showFeedDetails(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Feed Intake Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('Date', item['event_date']?.toString().split('T').first ?? 'N/A'),
              _detailRow('Feed Type', (item['feed_type'] ?? 'N/A').toString().toUpperCase()),
              _detailRow('Quantity', '${item['quantity_kg']} kg'),
              const CustomDivider(),
              _detailRow('Cost (Ksh)', item['cost_ksh']?.toString() ?? 'N/A'),
              _detailRow('Supplier', item['supplier']?.toString() ?? 'N/A'),
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

class _AddEditFeedDialog extends StatefulWidget {
  final Map<String, dynamic>? currentBatch;
  final Map<String, dynamic>? item;

  const _AddEditFeedDialog({this.currentBatch, this.item});

  @override
  State<_AddEditFeedDialog> createState() => _AddEditFeedDialogState();
}

class _AddEditFeedDialogState extends State<_AddEditFeedDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _costController;
  late final TextEditingController _supplierController;
  late final TextEditingController _notesController;

  String _selectedFeedType = 'starter';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.item?['quantity_kg']?.toString() ?? '');
    _costController = TextEditingController(text: widget.item?['cost_ksh']?.toString() ?? '');
    _supplierController = TextEditingController(text: widget.item?['supplier'] ?? '');
    _notesController = TextEditingController(text: widget.item?['notes'] ?? '');
    _selectedFeedType = widget.item?['feed_type'] ?? 'starter';
  }

  @override
  void dispose() {
    _amountController.dispose();
    _costController.dispose();
    _supplierController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit(WidgetRef ref) async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) return;

    final batchId = widget.item?['flock_id'] ?? widget.currentBatch?['id'];
    if (batchId == null) {
      if (mounted) ToastService.showError(context, 'No batch selected');
      return;
    }

    setState(() => _isLoading = true);
    final payload = {
      'quantity_kg': amount,
      'feed_type': _selectedFeedType,
      'cost_ksh': _costController.text.trim().isEmpty ? null : double.tryParse(_costController.text.trim()),
      'supplier': _supplierController.text.trim().isEmpty ? null : _supplierController.text.trim(),
      'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    };

    try {
      if (widget.item != null) {
        await ApiClient.instance.put('${ApiEndpoints.feed}/${widget.item!['id']}', data: payload);
      } else {
        payload['event_id'] = const Uuid().v4();
        await ApiClient.instance.post('${ApiEndpoints.feed}?flock_id=$batchId', data: payload);
      }

      if (mounted) {
        Navigator.pop(context);
        ref.invalidate(feedProvider);
        ToastService.showSuccess(context, 'Feed record saved');
      }
    } catch (e) {
      if (mounted) ToastService.showError(context, 'Failed to save feed');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) => AlertDialog(
        title: Text(widget.item != null ? 'Edit Feed Record' : 'Add Feed Record'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomInput(
                  label: 'Amount (kg)',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  controller: _amountController,
                  validator: (v) => (double.tryParse(v ?? '') ?? 0.0) <= 0 ? 'Enter valid amount' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _selectedFeedType,
                  decoration: InputDecoration(
                    labelText: 'Feed Type',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: ['starter', 'grower', 'finisher']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t.toUpperCase())))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedFeedType = v);
                  },
                ),
                const SizedBox(height: 12),
                CustomInput(
                  label: 'Cost (Ksh, Optional)',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  controller: _costController,
                ),
                const SizedBox(height: 12),
                CustomInput(label: 'Supplier (Optional)', controller: _supplierController),
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

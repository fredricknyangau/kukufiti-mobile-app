import 'package:mobile/presentation/widgets/custom_divider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/utils/toast_service.dart';
import '../../../../presentation/widgets/app_drawer.dart';
import '../../../../presentation/widgets/custom_button.dart';
import '../../../../presentation/widgets/custom_card.dart';
import '../../../../presentation/widgets/custom_input.dart';
import '../../../../providers/data_providers.dart';
import '../../../../providers/broiler_provider.dart';

class ExpendituresScreen extends ConsumerWidget {
  const ExpendituresScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final expAsync = ref.watch(expendituresProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Expenditures', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(expendituresProvider),
        child: expAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: $err'),
                ElevatedButton(onPressed: () => ref.invalidate(expendituresProvider), child: const Text('Retry')),
              ],
            ),
          ),
          data: (records) {
            final sortedRecords = List<dynamic>.from(records)
              ..sort((a, b) {
                final dateA = DateTime.tryParse(a['date']?.toString() ?? '') ?? DateTime(2000);
                final dateB = DateTime.tryParse(b['date']?.toString() ?? '') ?? DateTime(2000);
                return dateB.compareTo(dateA);
              });
            
            final categoryTotals = <String, double>{};
            for (final record in records) {
               final cat = record['category']?.toString() ?? 'Other';
               final amt = double.tryParse(record['amount']?.toString() ?? '') ?? 0.0;
               categoryTotals[cat] = (categoryTotals[cat] ?? 0) + amt;
            }
            final totalExp = categoryTotals.values.fold<double>(0, (prev, e) => prev + e);

            final defaultColors = [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
              theme.colorScheme.error,
              theme.colorScheme.tertiary,
              theme.colorScheme.outline
            ];

            final sections = categoryTotals.entries.toList().asMap().map((index, entry) {
               final percentage = totalExp > 0 ? (entry.value / totalExp) * 100 : 0.0;
               return MapEntry(index, PieChartSectionData(
                 color: defaultColors[index % defaultColors.length],
                 value: percentage,
                 title: percentage > 10 ? '${percentage.toStringAsFixed(0)}%' : '',
                 radius: 50,
                 titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 10),
               ));
            }).values.toList();

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
                          'Expenses by Category',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),
                        if (sections.isEmpty)
                           const SizedBox(
                             height: 200,
                             child: Center(child: Text('No expenditure data')),
                           )
                        else
                          SizedBox(
                            height: 200,
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 2,
                                centerSpaceRadius: 40,
                                sections: sections,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Recent Transactions',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (records.isEmpty)
                    CustomCard(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Text(
                            'No expenditure records available.',
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
                        final item = sortedRecords[index];
                        final dateStr = item['date']?.toString() ?? DateTime.now().toIso8601String();
                        final date = DateTime.tryParse(dateStr) ?? DateTime.now();
                        
                        return CustomCard(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                               backgroundColor: theme.colorScheme.primary.withAlpha(25),
                               child: Icon(LucideIcons.banknote, color: theme.colorScheme.primary),
                            ),
                            title: Text(
                              NumberFormat.currency(locale: 'en_KE', symbol: 'KES ').format(double.tryParse(item['amount']?.toString() ?? '') ?? 0.0), 
                              style: const TextStyle(fontWeight: FontWeight.bold)
                            ),
                            subtitle: Text('${item['category'] ?? 'Other'} - ${DateFormat('MMM dd, yyyy').format(date)}'),
                            trailing: PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert),
                              onSelected: (value) async {
                                if (value == 'edit') {
                                  _showAddExpenditureDialog(context, ref, item: item);
                                } else if (value == 'delete') {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Delete expenditure?'),
                                      content: const Text('This action cannot be undone.'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    try {
                                      await ApiClient.instance.delete('${ApiEndpoints.expenditures}/${item['id']}');
                                      ref.invalidate(expendituresProvider);
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
                            onTap: () => _showExpenditureDetails(context, item),
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
        onPressed: () => _showAddExpenditureDialog(context, ref),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(LucideIcons.plus),
      ),
    );
  }

  void _showAddExpenditureDialog(BuildContext context, WidgetRef ref, {Map<String, dynamic>? item}) {
    showDialog(
      context: context,
      builder: (ctx) => _AddExpenditureDialog(item: item),
    );
  }

  void _showExpenditureDetails(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Expenditure Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(item['description'] ?? 'No Description', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const CustomDivider(),
              _detailRow('Amount', 'KES ${item['amount']}', isBold: true),
              _detailRow('Category', item['category']?.toString().toUpperCase() ?? 'OTHER'),
              _detailRow('Date', item['date']?.toString().split('T').first ?? 'N/A'),
              const CustomDivider(),
              if (item['quantity'] != null) _detailRow('Quantity', '${item['quantity']} ${item['unit'] ?? ''}'),
              if (item['mpesa_transaction_id'] != null) _detailRow('M-Pesa ID', '${item['mpesa_transaction_id']}'),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
      ),
    );
  }

  static Widget _detailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}

class _AddExpenditureDialog extends ConsumerStatefulWidget {
  final Map<String, dynamic>? item;
  const _AddExpenditureDialog({this.item});

  @override
  ConsumerState<_AddExpenditureDialog> createState() => _AddExpenditureDialogState();
}

class _AddExpenditureDialogState extends ConsumerState<_AddExpenditureDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  final _newInvNameController = TextEditingController();
  final _newInvUnitController = TextEditingController();
  final _quantityController = TextEditingController();

  String _category = 'other';
  String? _selectedFlockId;
  String? _selectedInventoryId;
  bool _createInventoryItem = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _amountController.text = (widget.item!['amount'] ?? '').toString();
      _descController.text = widget.item!['description'] ?? '';
      _category = widget.item!['category'] ?? 'other';
      _selectedFlockId = widget.item!['flock_id'];
      _selectedInventoryId = widget.item!['inventory_item_id'];
      _quantityController.text = (widget.item!['quantity'] ?? '').toString();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    _newInvNameController.dispose();
    _newInvUnitController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    final amount = double.parse(_amountController.text); // Guaranteed safe by validator

    setState(() => _isLoading = true);
    
    final payload = {
      'amount': amount,
      'category': _category,
      'description': _descController.text.trim().isEmpty ? 'Expenditure' : _descController.text.trim(),
      'date': DateTime.now().toIso8601String().split('T').first,
      'flock_id': _selectedFlockId,
      'inventory_item_id': _selectedInventoryId,
      'create_inventory_item': _createInventoryItem,
      'new_inventory_name': _createInventoryItem ? _newInvNameController.text.trim() : null,
      'new_inventory_unit': _createInventoryItem ? _newInvUnitController.text.trim() : null,
      'quantity': double.tryParse(_quantityController.text) ?? 0,
    };

    try {
      if (widget.item != null) {
        await ApiClient.instance.put('${ApiEndpoints.expenditures}/${widget.item!['id']}', data: payload);
      } else {
        await ApiClient.instance.post(ApiEndpoints.expenditures, data: payload);
      }
      if (mounted) {
        Navigator.pop(context);
        ref.invalidate(expendituresProvider);
        if (_createInventoryItem || _selectedInventoryId != null) {
          ref.invalidate(inventoryProvider);
        }
        ToastService.showSuccess(context, 'Expenditure logged successfully');
      }
    } catch (e) {
      if (mounted) ToastService.showError(context, 'Failed to log expenditure');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final inventoryAsync = ref.watch(inventoryProvider);
    final broilerState = ref.watch(broilerProvider);

    return AlertDialog(
      title: const Text('Log Expenditure'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomInput(
                label: 'Amount (KES)',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                controller: _amountController,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  final amt = double.tryParse(v);
                  if (amt == null) return 'Enter a valid number';
                  if (amt <= 0) return 'Must be greater than 0';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: ['feed', 'medicine', 'equipment', 'labor', 'rent', 'other']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c.toUpperCase())))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _category = v);
                },
              ),
              const SizedBox(height: 12),
              CustomInput(label: 'Description', controller: _descController),
              const SizedBox(height: 12),
              
              if (broilerState.batches.isNotEmpty) ...[
                DropdownButtonFormField<String>(
                  initialValue: _selectedFlockId,
                  decoration: InputDecoration(
                    labelText: 'Allocate to Flock (Optional)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: [
                    const DropdownMenuItem<String>(value: null, child: Text('None')),
                    ...broilerState.batches
                        .map((b) => DropdownMenuItem<String>(
                              value: b['id']?.toString(),
                              child: Text(b['name'] ?? 'Unnamed'),
                            )),
                  ],
                  onChanged: (v) => setState(() => _selectedFlockId = v),
                ),
                const SizedBox(height: 12),
              ],

              inventoryAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => const Text('Error loading inventory dropdown'),
                data: (items) {
                  return Column(
                    children: [
                      if (!_createInventoryItem) ...[
                        DropdownButtonFormField<String>(
                          initialValue: _selectedInventoryId,
                          decoration: InputDecoration(
                            labelText: 'Link to Inventory (Optional)',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          items: [
                            const DropdownMenuItem<String>(value: null, child: Text('None')),
                            ...items.map((i) => DropdownMenuItem<String>(
                                  value: i['id']?.toString(),
                                  child: Text('${i['name']} (${i['quantity'] ?? 0} ${i['unit'] ?? ''})'),
                                )),
                          ],
                          onChanged: (v) => setState(() => _selectedInventoryId = v),
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (_selectedInventoryId != null || _createInventoryItem) ...[
                        CustomInput(
                          label: 'Item Quantity',
                          hintText: 'e.g. 5',
                          controller: _quantityController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Required when linked';
                            final qty = double.tryParse(v);
                            if (qty == null) return 'Enter valid quantity';
                            if (qty <= 0) return 'Must be greater than 0';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (_selectedInventoryId == null) ...[
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Add to Inventory?'),
                          value: _createInventoryItem,
                          onChanged: (v) => setState(() => _createInventoryItem = v ?? false),
                        ),
                        if (_createInventoryItem) ...[
                          CustomInput(
                            label: 'Item Name', 
                            hintText: 'e.g. Broiler Starter', 
                            controller: _newInvNameController,
                            validator: (v) {
                              if (_createInventoryItem && (v == null || v.trim().isEmpty)) {
                                return 'Item name required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          CustomInput(
                            label: 'Unit', 
                            hintText: 'e.g. bags, kgs', 
                            controller: _newInvUnitController,
                            validator: (v) {
                              if (_createInventoryItem && (v == null || v.trim().isEmpty)) {
                                return 'Unit required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                        ],
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        CustomButton(
          text: 'Save',
          isLoading: _isLoading,
          onPressed: _submit,
        ),
      ],
    );
  }
}

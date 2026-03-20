import 'package:mobile/presentation/widgets/custom_divider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/utils/toast_service.dart';
import '../../../../presentation/widgets/app_drawer.dart';
import '../../../../presentation/widgets/custom_button.dart';
import '../../../../presentation/widgets/custom_card.dart';
import '../../../../presentation/widgets/custom_input.dart';
import '../../../../providers/data_providers.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inventoryAsync = ref.watch(inventoryProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Inventory', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(inventoryProvider),
        child: inventoryAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: $err'),
                ElevatedButton(onPressed: () => ref.invalidate(inventoryProvider), child: const Text('Retry')),
              ],
            ),
          ),
          data: (items) {
             if (items.isEmpty) {
                return ListView(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                    const Center(child: Text('No inventory records found.')),
                  ],
                );
             }

             final filteredItems = items.where((item) {
               final name = (item['name'] ?? item['item_name'] ?? '').toString().toLowerCase();
               return name.contains(_searchQuery.toLowerCase());
             }).toList();

             return Column(
               children: [
                 Padding(
                   padding: const EdgeInsets.all(16.0),
                   child: CustomInput(
                     label: '',
                     hintText: 'Search items...',
                     prefixIcon: Icon(LucideIcons.search, size: 20, color: theme.colorScheme.primary),
                     onChanged: (v) => setState(() => _searchQuery = v),
                   ),
                 ),
                 if (filteredItems.isEmpty)
                   const Expanded(child: Center(child: Text('No items match search.')))
                 else
                   Expanded(
                     child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        final status = item['status']?.toString() ?? 'Stocked';
                        final isLow = status.toLowerCase().contains('low') || status.toLowerCase().contains('out');
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: CustomCard(
                            isPremium: true,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              leading: CircleAvatar(
                                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                                child: Icon(LucideIcons.package2, color: theme.colorScheme.primary),
                              ),
                              title: Text(item['name'] ?? item['item_name'] ?? 'Unknown Item', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('Quantity: ${item['quantity'] ?? 0} ${item['unit'] ?? 'units'}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isLow ? theme.colorScheme.error.withValues(alpha: 0.1) : theme.colorScheme.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      status,
                                      style: TextStyle(
                                        color: isLow ? theme.colorScheme.error : theme.colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    icon: const Icon(LucideIcons.moreVertical, size: 20),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onSelected: (value) async {
                                      if (value == 'edit') {
                                        _showAddEditItemDialog(context, ref, item: item);
                                      } else if (value == 'restock') {
                                        _showAddEditItemDialog(context, ref, item: item, isRestock: true);
                                      } else if (value == 'delete') {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text('Delete Item?'),
                                            content: const Text('This action cannot be undone.'),
                                            actions: [
                                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          try {
                                            await ApiClient.instance.delete('${ApiEndpoints.inventory}${item['id']}');
                                            ref.invalidate(inventoryProvider);
                                          } catch (e) {
                                            if (context.mounted) ToastService.showError(context, 'Failed to delete: $e');
                                          }
                                        }
                                      }
                                    },
                                    itemBuilder: (context) => const [
                                      PopupMenuItem(value: 'restock', child: Text('Update Stock')),
                                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                                      PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                                    ],
                                  ),
                                ],
                              ),
                              onTap: () => _showItemHistory(context, ref, item),
                            ),
                          ),
                        );
                      },
                    ),
                   ),
               ],
             );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditItemDialog(context, ref),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(LucideIcons.plus),
      ),
    );
  }

  void _showAddEditItemDialog(BuildContext context, WidgetRef ref, {Map<String, dynamic>? item, bool isRestock = false}) {
    showDialog(
      context: context,
      builder: (ctx) => _AddEditItemDialog(item: item, isRestock: isRestock),
    );
  }

  void _showItemHistory(BuildContext context, WidgetRef ref, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (ctx) => Consumer(
        builder: (context, ref, child) {
          final historyAsync = ref.watch(inventoryHistoryProvider(item['id'].toString()));
          return AlertDialog(
            title: Text('${item['name'] ?? 'Item'} History'),
            content: SizedBox(
              width: double.maxFinite,
              height: 300,
              child: historyAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error loading history: $e')),
                data: (logs) {
                  if (logs.isEmpty) return const Center(child: Text('No history available.'));
                  return ListView.separated(
                    itemCount: logs.length,
                    separatorBuilder: (_, _) => const CustomDivider(),
                    itemBuilder: (ctx, i) {
                      final log = logs[i];
                      final dateStr = log['date']?.toString() ?? log['created_at']?.toString() ?? '';
                      final date = DateTime.tryParse(dateStr) ?? DateTime.now();
                      final change = (log['quantity_change'] as num?)?.toDouble() ?? 0.0;
                      final isPositive = change > 0;
                      
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(log['action']?.toString().toUpperCase() ?? 'ADJUSTMENT', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        subtitle: Text(log['notes'] ?? 'No notes', style: const TextStyle(fontSize: 12)),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${isPositive ? '+' : ''}$change',
                              style: TextStyle(
                                color: isPositive ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(DateFormat('MMM dd, yyyy').format(date), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
          );
        },
      ),
    );
  }
}

class _AddEditItemDialog extends StatefulWidget {
  final Map<String, dynamic>? item;
  final bool isRestock;

  const _AddEditItemDialog({this.item, this.isRestock = false});

  @override
  State<_AddEditItemDialog> createState() => _AddEditItemDialogState();
}

class _AddEditItemDialogState extends State<_AddEditItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _quantityController;
  late final TextEditingController _unitController;
  late final TextEditingController _minStockController;
  late final TextEditingController _costController;
  late final TextEditingController _notesController;

  String _category = 'other';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?['name'] ?? widget.item?['item_name'] ?? '');
    _quantityController = TextEditingController(text: widget.isRestock ? '' : (widget.item?['quantity'] ?? '').toString());
    _unitController = TextEditingController(text: widget.item?['unit'] ?? '');
    _minStockController = TextEditingController(text: (widget.item?['minimum_stock'] ?? '0').toString());
    _costController = TextEditingController(text: (widget.item?['cost_per_unit'] ?? '0').toString());
    _notesController = TextEditingController(text: widget.item?['notes'] ?? '');
    _category = widget.item?['category'] ?? 'other';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _minStockController.dispose();
    _costController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit(WidgetRef ref) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    
    final qty = double.tryParse(_quantityController.text) ?? 0.0;
    final minStock = double.tryParse(_minStockController.text) ?? 0.0;
    final cost = double.tryParse(_costController.text) ?? 0.0;

    try {
      if (widget.item != null) {
        // Edit or Restock
        final payload = <String, dynamic>{};
        if (widget.isRestock) {
          final oldQty = double.tryParse(widget.item!['quantity']?.toString() ?? '0') ?? 0.0;
          payload['quantity'] = oldQty + qty;
          payload['notes'] = _notesController.text.trim().isEmpty ? 'Restocked' : _notesController.text.trim();
        } else {
          payload['name'] = _nameController.text.trim();
          payload['category'] = _category;
          payload['quantity'] = qty;
          payload['unit'] = _unitController.text.trim();
          payload['minimum_stock'] = minStock;
          payload['cost_per_unit'] = cost;
          payload['notes'] = _notesController.text.trim();
        }

        await ApiClient.instance.put('${ApiEndpoints.inventory}${widget.item!['id']}', data: payload);
      } else {
        // Create
        await ApiClient.instance.post(ApiEndpoints.inventory, data: {
          'name': _nameController.text.trim(),
          'category': _category,
          'quantity': qty,
          'unit': _unitController.text.isEmpty ? 'units' : _unitController.text.trim(),
          'minimum_stock': minStock,
          'cost_per_unit': cost,
          'notes': _notesController.text.trim(),
        });
      }

      if (mounted) {
        Navigator.pop(context);
        ref.invalidate(inventoryProvider);
        ToastService.showSuccess(context, widget.isRestock ? 'Stock updated' : 'Inventory saved');
      }
    } catch (e) {
      if (mounted) ToastService.showError(context, 'Failed to save item');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) => AlertDialog(
        title: Text(widget.isRestock ? 'Update Stock: ${_nameController.text}' : (widget.item != null ? 'Edit Item' : 'Add Item')),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!widget.isRestock) ...[
                  CustomInput(
                    label: 'Item Name',
                    hintText: 'e.g. Disinfectant',
                    controller: _nameController,
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _category,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: ['other', 'feed', 'medicine', 'equipment']
                        .map((t) => DropdownMenuItem(value: t, child: Text(t.toUpperCase())))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _category = v);
                    },
                  ),
                  const SizedBox(height: 12),
                ],
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: CustomInput(
                        label: widget.isRestock ? 'Add Quantity' : 'Quantity',
                        hintText: 'e.g. 5',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        controller: _quantityController,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          final qty = double.tryParse(v);
                          if (qty == null) return 'Enter valid number';
                          if (qty <= 0) return 'Must be greater than 0';
                          return null;
                        },
                      ),
                    ),
                    if (!widget.isRestock) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomInput(
                          label: 'Unit',
                          hintText: 'e.g. L, kg',
                          controller: _unitController,
                        ),
                      ),
                    ],
                  ],
                ),
                if (!widget.isRestock) ...[
                  const SizedBox(height: 12),
                  CustomInput(
                    label: 'Minimum Stock Alert',
                    hintText: 'e.g. 10',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    controller: _minStockController,
                    validator: (v) {
                      if (v == null || v.isEmpty) return null;
                      if (double.tryParse(v) == null) return 'Enter valid number';
                      if (double.parse(v) < 0) return 'Cannot be negative';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  CustomInput(
                    label: 'Cost per Unit (KES)',
                    hintText: '0',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    controller: _costController,
                    validator: (v) {
                      if (v == null || v.isEmpty) return null;
                      if (double.tryParse(v) == null) return 'Enter valid number';
                      if (double.parse(v) < 0) return 'Cannot be negative';
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 12),
                CustomInput(
                  label: 'Notes / Supplier',
                  controller: _notesController,
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
            onPressed: () => _submit(ref),
          ),
        ],
      ),
    );
  }
}

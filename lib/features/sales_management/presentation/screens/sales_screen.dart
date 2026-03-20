import 'package:mobile/presentation/widgets/custom_divider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/network/api_client.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../presentation/widgets/app_drawer.dart';
import '../../../../presentation/widgets/custom_button.dart';
import '../../../../presentation/widgets/custom_card.dart';
import '../../../../presentation/widgets/custom_input.dart';
import '../../../../core/utils/toast_service.dart';
import '../../../../providers/data_providers.dart';
import '../../../../providers/broiler_provider.dart';

class SalesScreen extends ConsumerWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final salesAsync = ref.watch(salesProvider);
    final broilerState = ref.watch(broilerProvider);
    final currentBatch = broilerState.currentBatch;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Sales & Revenue', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(salesProvider),
        child: salesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: $err'),
                ElevatedButton(onPressed: () => ref.invalidate(salesProvider), child: const Text('Retry')),
              ],
            ),
          ),
          data: (records) {
            final sortedRecords = List<dynamic>.from(records)
              ..sort((a, b) {
                final dateA = DateTime.tryParse(a['date']?.toString() ?? '') ?? DateTime(2000);
                final dateB = DateTime.tryParse(b['date']?.toString() ?? '') ?? DateTime(2000);
                return dateA.compareTo(dateB);
              });

            final totalRev = records.fold<double>(0, (prev, e) => prev + (double.tryParse(e['total_amount']?.toString() ?? '') ?? 0.0));
            
            final spots = <FlSpot>[];
            for (int i = 0; i < sortedRecords.length; i++) {
              spots.add(FlSpot(i.toDouble(), double.tryParse(sortedRecords[i]['total_amount']?.toString() ?? '') ?? 0.0));
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
                         Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Revenue',
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              NumberFormat.currency(locale: 'en_KE', symbol: 'KES ').format(totalRev),
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 24),
                        if (spots.isEmpty)
                          const SizedBox(
                            height: 200,
                            child: Center(child: Text('No chart data')),
                          )
                        else
                          SizedBox(
                            height: 200,
                            child: LineChart(
                              LineChartData(
                                gridData: const FlGridData(show: false),
                                titlesData: const FlTitlesData(
                                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                    'Sales History',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (records.isEmpty)
                    CustomCard(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Text(
                            'No sales records available.',
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
                              NumberFormat.currency(locale: 'en_KE', symbol: 'KES ').format(double.tryParse(item['total_amount']?.toString() ?? '') ?? 0.0), 
                              style: const TextStyle(fontWeight: FontWeight.bold)
                            ),
                            subtitle: Text('${item['quantity'] ?? 0} birds - ${DateFormat('MMM dd, yyyy').format(date)}'),
                            trailing: PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert),
                              onSelected: (value) async {
                                if (value == 'edit') {
                                  _showAddEditSalesDialog(context, ref, currentBatch, item: item);
                                } else if (value == 'delete') {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Delete sale?'),
                                      content: const Text('This action cannot be undone.'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    try {

                                      await ApiClient.instance.delete('${ApiEndpoints.sales}/${item['id']}');

                                      ref.invalidate(salesProvider);

                                    } catch (e) {

                                      if (context.mounted) {

                                        String message = 'Failed to delete';

                                        if (e is DioException && e.response?.statusCode == 404) {

                                          message = 'Record already deleted';

                                          ref.invalidate(salesProvider);

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
                            onTap: () => _showSaleDetails(context, item),
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
        onPressed: () => _showAddEditSalesDialog(context, ref, currentBatch),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(LucideIcons.plus),
      ),
    );
  }

  void _showAddEditSalesDialog(BuildContext context, WidgetRef ref, Map<String, dynamic>? currentBatch, {Map<String, dynamic>? item}) {
    showDialog(
      context: context,
      builder: (ctx) => _AddEditSaleDialog(currentBatch: currentBatch, item: item),
    );
  }

  void _showSaleDetails(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sale Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Buyer: ${item['buyer_name'] ?? 'Walk-in'}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              if (item['buyer_phone']?.toString().isNotEmpty == true) Text('Phone: ${item['buyer_phone']}'),
              const CustomDivider(),
              _detailRow('Date', item['date']?.toString().split('T').first ?? 'N/A'),
              _detailRow('Quantity', '${item['quantity'] ?? 0} birds'),
              _detailRow('Price per Bird', 'KES ${item['price_per_bird'] ?? 0}'),
              _detailRow('Total Amount', 'KES ${item['total_amount'] ?? 0}', isBold: true),
              const CustomDivider(),
              if (item['average_weight_grams'] != null) _detailRow('Avg Weight', '${item['average_weight_grams']} g'),
              if (item['mpesa_transaction_id'] != null) _detailRow('M-Pesa ID', '${item['mpesa_transaction_id']}'),
              if (item['notes']?.toString().isNotEmpty == true) _detailRow('Notes', '${item['notes']}'),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool isBold = false}) {
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

class _AddEditSaleDialog extends StatefulWidget {
  final Map<String, dynamic>? currentBatch;
  final Map<String, dynamic>? item;

  const _AddEditSaleDialog({this.currentBatch, this.item});

  @override
  State<_AddEditSaleDialog> createState() => _AddEditSaleDialogState();
}

class _AddEditSaleDialogState extends State<_AddEditSaleDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _quantityController;
  late final TextEditingController _priceController;
  late final TextEditingController _amountController;
  late final TextEditingController _buyerNameController;
  late final TextEditingController _buyerPhoneController;
  late final TextEditingController _notesController;
  late final TextEditingController _mpesaController;
  late final TextEditingController _weightController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(text: widget.item?['quantity']?.toString() ?? '');
    _priceController = TextEditingController(text: widget.item?['price_per_bird']?.toString() ?? '');
    _amountController = TextEditingController(text: widget.item?['total_amount']?.toString() ?? '');
    _buyerNameController = TextEditingController(text: widget.item?['buyer_name'] ?? '');
    _buyerPhoneController = TextEditingController(text: widget.item?['buyer_phone'] ?? '');
    _notesController = TextEditingController(text: widget.item?['notes'] ?? '');
    _mpesaController = TextEditingController(text: widget.item?['mpesa_transaction_id'] ?? '');
    _weightController = TextEditingController(text: widget.item?['average_weight_grams']?.toString() ?? '');

    _quantityController.addListener(_calculateTotal);
    _priceController.addListener(_calculateTotal);
  }

  void _calculateTotal() {
    final qty = int.tryParse(_quantityController.text) ?? 0;
    final price = double.tryParse(_priceController.text) ?? 0.0;
    if (qty > 0 && price > 0) {
      _amountController.text = (qty * price).toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    _amountController.dispose();
    _buyerNameController.dispose();
    _buyerPhoneController.dispose();
    _notesController.dispose();
    _mpesaController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _submit(WidgetRef ref) async {
    if (!_formKey.currentState!.validate()) return;

    final quantity = int.tryParse(_quantityController.text) ?? 0;
    final price = double.tryParse(_priceController.text) ?? 0.0;
    final amount = double.tryParse(_amountController.text) ?? 0.0;

    if (quantity <= 0 || price <= 0 || amount <= 0) return;

    final batchId = widget.item?['flock_id'] ?? widget.currentBatch?['id'];
    if (batchId == null) {
      if (mounted) ToastService.showError(context, 'No batch selected');
      return;
    }

    setState(() => _isLoading = true);
    final payload = {
      'quantity': quantity,
      'price_per_bird': price,
      'total_amount': amount,
      'buyer_name': _buyerNameController.text.trim().isEmpty ? 'Walk-in' : _buyerNameController.text.trim(),
      'buyer_phone': _buyerPhoneController.text.trim().isEmpty ? null : _buyerPhoneController.text.trim(),
      'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      'mpesa_transaction_id': _mpesaController.text.trim().isEmpty ? null : _mpesaController.text.trim(),
      'average_weight_grams': _weightController.text.trim().isEmpty ? null : double.tryParse(_weightController.text.trim()),
      'date': widget.item?['date'] ?? DateFormat('yyyy-MM-dd').format(DateTime.now()),
    };

    try {
      if (widget.item != null) {
        await ApiClient.instance.put('${ApiEndpoints.sales}/${widget.item!['id']}', data: payload);
      } else {
        payload['flock_id'] = batchId;
        await ApiClient.instance.post(ApiEndpoints.sales, data: payload);
      }

      if (mounted) {
        Navigator.pop(context);
        ref.invalidate(salesProvider);
        ToastService.showSuccess(context, 'Sale saved successfully');
      }
    } catch (e) {
      if (mounted) ToastService.showError(context, 'Failed to save sale');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) => AlertDialog(
        title: Text(widget.item != null ? 'Edit Sale' : 'Log Sale'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomInput(
                  label: 'Quantity (Birds) *',
                  keyboardType: TextInputType.number,
                  controller: _quantityController,
                  validator: (v) => (int.tryParse(v ?? '') ?? 0) <= 0 ? 'Enter valid qty' : null,
                ),
                const SizedBox(height: 12),
                CustomInput(
                  label: 'Price per Bird (KES) *',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  controller: _priceController,
                  validator: (v) => (double.tryParse(v ?? '') ?? 0) <= 0 ? 'Enter valid price' : null,
                ),
                const SizedBox(height: 12),
                CustomInput(
                  label: 'Total Amount (KES) *',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  controller: _amountController,
                  validator: (v) => (double.tryParse(v ?? '') ?? 0) <= 0 ? 'Enter valid amount' : null,
                ),
                const SizedBox(height: 12),
                CustomInput(label: 'Buyer Name', controller: _buyerNameController),
                const SizedBox(height: 12),
                CustomInput(label: 'Buyer Phone', controller: _buyerPhoneController, keyboardType: TextInputType.phone),
                const SizedBox(height: 12),
                CustomInput(
                  label: 'Avg Weight (grams, Optional)',
                  controller: _weightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 12),
                CustomInput(label: 'M-Pesa ID (Optional)', controller: _mpesaController),
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

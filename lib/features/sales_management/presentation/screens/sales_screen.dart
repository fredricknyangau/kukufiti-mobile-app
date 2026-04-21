import 'package:mobile/shared/widgets/custom_divider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mobile/app/theme/app_theme.dart';

import 'package:mobile/core/network/api_client.dart';
import 'package:dio/dio.dart';
import 'package:mobile/core/network/api_endpoints.dart';
import 'package:mobile/shared/widgets/app_drawer.dart';
import 'package:mobile/shared/widgets/custom_button.dart';
import 'package:mobile/shared/widgets/custom_card.dart';
import 'package:mobile/shared/widgets/custom_input.dart';
import 'package:mobile/core/utils/toast_service.dart';
import 'package:mobile/shared/providers/data_providers.dart';
import 'package:mobile/core/models/broiler_models.dart';
import 'package:mobile/core/services/sync_service.dart';

class SalesScreen extends ConsumerWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final salesAsync = ref.watch(salesProvider);
    final broilerState = ref.watch(broilerProvider);
    final profileAsync = ref.watch(profileProvider);
    final user = profileAsync.value;
    final canEdit = user?.canEdit ?? false;
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
            final sortedRecords = List<SaleRecord>.from(records)
              ..sort((a, b) => a.date.compareTo(b.date));

            final totalRev = records.fold<double>(0, (prev, e) => prev + e.totalAmount);
            
            final spots = <FlSpot>[];
            for (int i = 0; i < sortedRecords.length; i++) {
              spots.add(FlSpot(i.toDouble(), sortedRecords[i].totalAmount));
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
                        
                        return CustomCard(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                               backgroundColor: theme.colorScheme.primary.withAlpha(25),
                               child: Icon(LucideIcons.banknote, color: theme.colorScheme.primary),
                            ),
                            title: Text(
                              NumberFormat.currency(locale: 'en_KE', symbol: 'KES ').format(item.totalAmount), 
                              style: const TextStyle(fontWeight: FontWeight.bold)
                            ),
                            subtitle: Text('${item.quantity} birds - ${DateFormat('MMM dd, yyyy').format(item.date)}'),
                            trailing: canEdit
                                ? PopupMenuButton<String>(
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
                                              TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Delete', style: TextStyle(color: theme.colorScheme.error))),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          try {
                                            await ApiClient.instance.delete('${ApiEndpoints.sales}/${item.id}');
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
                                    itemBuilder: (ctx) => [
                                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                      PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: theme.colorScheme.error))),
                                    ],
                                  )
                                : null,
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
      floatingActionButton: canEdit
          ? FloatingActionButton(
              onPressed: () => _showAddEditSalesDialog(context, ref, currentBatch),
              backgroundColor: theme.colorScheme.tertiary,
              foregroundColor: theme.colorScheme.onTertiary,
              child: const Icon(LucideIcons.plus),
            )
          : null,
    );
  }

  void _showAddEditSalesDialog(BuildContext context, WidgetRef ref, Batch? currentBatch, {SaleRecord? item}) {
    showDialog(
      context: context,
      builder: (ctx) => _AddEditSaleDialog(currentBatch: currentBatch, item: item),
    );
  }

  void _showSaleDetails(BuildContext context, SaleRecord item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sale Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Buyer: ${item.buyerName ?? 'Walk-in'}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              if (item.buyerPhone?.isNotEmpty == true) Text('Phone: ${item.buyerPhone}'),
              const CustomDivider(),
              _detailRow(ctx, 'Date', DateFormat('yyyy-MM-dd').format(item.date)),
              _detailRow(ctx, 'Quantity', '${item.quantity} units'),
              _detailRow(ctx, 'Unit Price', 'KES ${item.pricePerBird.toStringAsFixed(2)}'),
              _detailRow(ctx, 'Total', 'KES ${item.totalAmount.toStringAsFixed(2)}', isBold: true),
              const CustomDivider(),
              _detailRow(ctx, 'Customer', item.buyerName?.isNotEmpty == true ? item.buyerName! : 'Walk-in'),
              _detailRow(ctx, 'Phone', item.buyerPhone?.isNotEmpty == true ? item.buyerPhone! : 'N/A'),
              // Assuming paymentStatus is a field in SaleRecord
              // _detailRow(ctx, 'Payment', item.paymentStatus.toUpperCase()), // This line was in the instruction but paymentStatus is not in SaleRecord
              if (item.mpesaTransactionId != null) _detailRow(ctx, 'M-Pesa ID', '${item.mpesaTransactionId}'),
              if (item.notes?.isNotEmpty == true) _detailRow(ctx, 'Notes', '${item.notes}'),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
      ),
    );
  }

  Widget _detailRow(BuildContext context, String label, String value, {bool isBold = false}) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: customColors.neutral!)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}

class _AddEditSaleDialog extends StatefulWidget {
  final Batch? currentBatch;
  final SaleRecord? item;

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
  String? _selectedCustomerId;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(text: widget.item?.quantity.toString() ?? '');
    _priceController = TextEditingController(text: widget.item?.pricePerBird.toString() ?? '');
    _amountController = TextEditingController(text: widget.item?.totalAmount.toString() ?? '');
    _buyerNameController = TextEditingController(text: widget.item?.buyerName ?? '');
    _buyerPhoneController = TextEditingController(text: widget.item?.buyerPhone ?? '');
    _notesController = TextEditingController(text: widget.item?.notes ?? '');
    _mpesaController = TextEditingController(text: widget.item?.mpesaTransactionId ?? '');
    _weightController = TextEditingController(text: widget.item?.averageWeight?.toString() ?? '');
    _selectedCustomerId = widget.item?.customerId;

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

    final batchId = widget.item?.batchId ?? widget.currentBatch?.id;
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
      'average_weight': _weightController.text.trim().isEmpty ? null : double.tryParse(_weightController.text.trim()),
      'customer_id': _selectedCustomerId,
      'date': widget.item?.date != null ? DateFormat('yyyy-MM-dd').format(widget.item!.date) : DateFormat('yyyy-MM-dd').format(DateTime.now()),
      'flock_id': batchId,
    };

    try {
      if (widget.item != null) {
        await ApiClient.instance.put('${ApiEndpoints.sales}/${widget.item!.id}', data: payload);
      } else {
        await ApiClient.instance.post(ApiEndpoints.sales, data: payload);
      }

      if (mounted) {
        Navigator.pop(context);
        ref.invalidate(salesProvider);
        ToastService.showSuccess(context, 'Sale saved successfully');
      }
    } catch (e) {
      if (mounted) {
        if (e is DioException) {
          final isNetworkIssue = e.type == DioExceptionType.connectionTimeout || 
                               e.type == DioExceptionType.sendTimeout ||
                               e.type == DioExceptionType.receiveTimeout ||
                               e.type == DioExceptionType.connectionError ||
                               e.response == null;

          if (isNetworkIssue) {
            await SyncService.enqueueOperation(
              endpoint: widget.item != null 
                  ? '${ApiEndpoints.sales}/${widget.item!.id}' 
                  : ApiEndpoints.sales,
              method: widget.item != null ? 'PUT' : 'POST',
              data: payload,
            );
            if (!mounted) return;
            Navigator.pop(context);
            ToastService.showSuccess(context, 'Saved offline. Will sync when online.');
            return;
          }
        }
        ToastService.showError(context, 'Failed to save sale');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final customersAsync = ref.watch(customersProvider);
        return AlertDialog(
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
                customersAsync.when(
                  loading: () => const Text('Loading customers...'),
                  error: (e, _) => const Text('Error loading customers dropdown'),
                  data: (customers) {
                    return DropdownButtonFormField<String>(
                      initialValue: _selectedCustomerId,
                      decoration: InputDecoration(
                        labelText: 'Customer (Optional)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: [
                        const DropdownMenuItem<String>(value: null, child: Text('None')),
                        ...customers.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                      ],
                      onChanged: (v) => setState(() => _selectedCustomerId = v),
                    );
                  }
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
      );
    });
  }
}

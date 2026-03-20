import 'package:mobile/presentation/widgets/custom_divider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/utils/toast_service.dart';
import '../../../../providers/broiler_provider.dart';
import '../../../../presentation/widgets/app_drawer.dart';
import '../../../../presentation/widgets/custom_card.dart';
import '../../../../presentation/widgets/custom_input.dart';
import '../../../../presentation/widgets/custom_button.dart';

class BatchesScreen extends ConsumerWidget {
  const BatchesScreen({super.key});

  String _getFriendlyDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date).inDays;

      if (difference == 0) return 'Today';
      if (difference == 1) return 'Yesterday';
      if (difference < 7) return '$difference days ago';
      if (difference < 30) return '${(difference / 7).round()} weeks ago';
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final broilerState = ref.watch(broilerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Batch Management', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(broilerProvider.notifier).fetchBatches(),
        child: broilerState.isLoading && broilerState.batches.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : broilerState.error != null
                ? ListView(
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                      Center(
                        child: Text(
                          'Error: ${broilerState.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  )
                : broilerState.batches.isEmpty
                ? ListView(
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                      Center(
                        child: Text(
                          'No batches found.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withAlpha(180),
                          ),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: broilerState.batches.length,
                    itemBuilder: (context, index) {
                      final batch = broilerState.batches[index];
                      final startDateStr = batch['start_date'];
                      int daysElapsed = 0;
                      if (startDateStr != null) {
                        try {
                          final date = DateTime.parse(startDateStr.toString());
                          daysElapsed = DateTime.now().difference(date).inDays;
                        } catch (_) {}
                      }

                      final status = (batch['status'] ?? 'active').toString().toLowerCase();
                      Color statusColor;
                      switch (status) {
                        case 'active': statusColor = Colors.green; break;
                        case 'completed': statusColor = Colors.blue; break;
                        case 'sold': statusColor = Colors.orange; break;
                        default: statusColor = Colors.grey;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CustomCard(
                          isPremium: true,
                          child: InkWell(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              ref.read(broilerProvider.notifier).selectBatch(batch);
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary.withAlpha(25),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(LucideIcons.layers, color: theme.colorScheme.primary),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              batch['name'] ?? 'Batch #${batch['id'] ?? index + 1}',
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Started: ${_getFriendlyDate(startDateStr)}',
                                              style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(160), fontSize: 13),
                                            ),
                                          ],
                                        ),
                                      ),
                                      PopupMenuButton<String>(
                                        onSelected: (value) async {
                                          if (value == 'edit') {
                                            _showAddBatchSheet(context, ref, batch: batch);
                                          } else if (value == 'delete') {
                                            final confirm = await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text('Delete Batch?'),
                                                content: const Text('This action cannot be undone.'),
                                                actions: [
                                                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                                  TextButton(
                                                    onPressed: () {
                                                      HapticFeedback.mediumImpact();
                                                      Navigator.pop(context, true);
                                                    },
                                                    child: const Text('Delete', style: TextStyle(color: Colors.red))
                                                  ),
                                                ],
                                              ),
                                            );
                                            if (confirm == true) {
                                              try {
                                                await ApiClient.instance.delete('${ApiEndpoints.batches}${batch['id']}');
                                                ref.read(broilerProvider.notifier).fetchBatches();
                                              } catch (e) {
                                                if (context.mounted) ToastService.showError(context, 'Failed to delete: $e');
                                              }
                                            }
                                          }
                                        },
                                        itemBuilder: (context) => const [
                                          PopupMenuItem(value: 'edit', child: Text('Edit')),
                                          PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    child: CustomDivider(height: 1),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(LucideIcons.users, size: 16, color: theme.colorScheme.primary),
                                          const SizedBox(width: 6),
                                          Text(
                                            '${batch['initial_count'] ?? batch['batch_size'] ?? 'N/A'} Birds',
                                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                      if (daysElapsed > 0)
                                        Row(
                                          children: [
                                            Icon(LucideIcons.calendar, size: 16, color: theme.colorScheme.secondary),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Day $daysElapsed',
                                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: statusColor.withAlpha(25),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: statusColor.withAlpha(80)),
                                        ),
                                        child: Text(
                                          status.toUpperCase(),
                                          style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          _showAddBatchSheet(context, ref);
        },
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        child: const Icon(LucideIcons.plus),
      ),
    );
  }

  void _showAddBatchSheet(BuildContext context, WidgetRef ref, {Map<String, dynamic>? batch}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _AddBatchSheet(ref: ref, batch: batch),
    );
  }
}

class _AddBatchSheet extends StatefulWidget {
  final WidgetRef ref;
  final Map<String, dynamic>? batch;
  const _AddBatchSheet({required this.ref, this.batch});

  @override
  State<_AddBatchSheet> createState() => _AddBatchSheetState();
}

class _AddBatchSheetState extends State<_AddBatchSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _sizeController = TextEditingController();
  final _breedController = TextEditingController();
  String _status = 'active';
  DateTime? _startDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.batch != null) {
      _nameController.text = widget.batch!['name'] ?? '';
      _sizeController.text = (widget.batch!['initial_count'] ?? widget.batch!['batch_size'] ?? '').toString();
      _breedController.text = widget.batch!['breed'] ?? '';
      _status = (widget.batch!['status'] ?? 'active').toLowerCase();
      _startDate = DateTime.tryParse(widget.batch!['start_date'] ?? '') ?? DateTime.now();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sizeController.dispose();
    _breedController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.vibrate(); // Error feedback
      return;
    }

    setState(() => _isLoading = true);
    final data = {
      'name': _nameController.text.trim(),
      'initial_count': int.parse(_sizeController.text),
      'breed': _breedController.text.trim().isEmpty ? null : _breedController.text.trim(),
      'start_date': DateFormat('yyyy-MM-dd').format(_startDate!),
      'status': _status,
    };

    try {
      if (widget.batch != null) {
        await ApiClient.instance.put('${ApiEndpoints.batches}${widget.batch!['id']}', data: data);
      } else {
        await ApiClient.instance.post(ApiEndpoints.batches, data: data);
      }

      if (mounted) {
        HapticFeedback.heavyImpact(); // Success feedback
        ToastService.showSuccess(context, widget.batch != null ? 'Batch updated' : 'Batch created');
        widget.ref.read(broilerProvider.notifier).fetchBatches();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        HapticFeedback.vibrate();
        String message = widget.batch != null ? 'Failed to update batch' : 'Failed to create batch';
        if (e is DioException && e.response?.data is Map) {
          message = e.response!.data['detail'] ?? message;
        } else {
          message = '$message: $e';
        }
        ToastService.showError(context, message);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction, // Real-time validation
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.batch != null ? 'Edit Batch' : 'Add New Batch',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              CustomInput(
                label: 'Batch Name',
                hintText: 'e.g., Flock A - Q1',
                controller: _nameController,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              CustomInput(
                label: 'Initial Count',
                hintText: 'e.g., 500',
                controller: _sizeController,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  final count = int.tryParse(v);
                  if (count == null) return 'Enter a valid number';
                  if (count <= 0) return 'Must be greater than 0';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomInput(
                label: 'Breed (Optional)',
                hintText: 'e.g., Cobb 500, Kienyeji',
                controller: _breedController,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: ['active', 'completed', 'sold', 'culled', 'terminated']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase())))
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    HapticFeedback.selectionClick();
                    setState(() => _status = v);
                  }
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Start Date'),
                subtitle: Text(DateFormat('yyyy-MM-dd').format(_startDate!)),
                trailing: const Icon(LucideIcons.calendar),
                onTap: () async {
                  HapticFeedback.lightImpact();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _startDate!,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) setState(() => _startDate = picked);
                },
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: widget.batch != null ? 'Update Batch' : 'Create Batch',
                onPressed: _submit,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

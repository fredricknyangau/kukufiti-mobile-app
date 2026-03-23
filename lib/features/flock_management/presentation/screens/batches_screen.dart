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
import '../../../../core/utils/error_handler.dart';
import '../../../../providers/broiler_provider.dart';
import '../../../../providers/data_providers.dart';
import '../../../../presentation/widgets/app_drawer.dart';
import '../../../../presentation/widgets/custom_card.dart';
import '../../../../presentation/widgets/custom_input.dart';
import '../../../../presentation/widgets/custom_button.dart';
import '../../../../core/models/broiler_models.dart';
import '../../../../core/constants/broiler_constants.dart';

class BatchesScreen extends ConsumerWidget {
  const BatchesScreen({super.key});

  String _getFriendlyDate(DateTime? date) {
    if (date == null) return 'N/A';
    try {
      final now = DateTime.now();
      final difference = now.difference(date).inDays;

      if (difference == 0) return 'Today';
      if (difference == 1) return 'Yesterday';
      if (difference < 7) return '$difference days ago';
      if (difference < 30) return '${(difference / 7).round()} weeks ago';
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (_) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final broilerState = ref.watch(broilerProvider);
    final theme = Theme.of(context);
    final farms = ref.watch(farmsProvider).value ?? [];

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
                      final startDate = batch.commencementDate;
                      
                      // Note: Assuming farm linking still uses dynamic farm list for now
                      // as farm model wasn't in the provided list
                      final farm = farms.firstWhere((f) => f['id'].toString() == batch.sourceLocation, orElse: () => null);
                      final farmName = farm != null ? farm['name'] : null;

                      int daysElapsed = DateTime.now().difference(startDate).inDays;

                      final status = batch.status.toLowerCase();
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
                                              batch.name,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                            ),
                                            if (farmName != null)
                                              Padding(
                                                padding: const EdgeInsets.only(top: 4),
                                                child: Text(
                                                  'Farm: $farmName',
                                                  style: TextStyle(
                                                    color: theme.colorScheme.primary,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 0.2,
                                                  ),
                                                ),
                                              ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Started: ${_getFriendlyDate(startDate)}',
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
                                                await ApiClient.instance.delete('${ApiEndpoints.batches}${batch.id}');
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
                                            '${batch.initialChicks} Birds',
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

  void _showAddBatchSheet(BuildContext context, WidgetRef ref, {Batch? batch}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _AddBatchSheet(batch: batch),
    );
  }
}

class _AddBatchSheet extends ConsumerStatefulWidget {
  final Batch? batch;
  const _AddBatchSheet({this.batch});

  @override
  ConsumerState<_AddBatchSheet> createState() => _AddBatchSheetState();
}

class _AddBatchSheetState extends ConsumerState<_AddBatchSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _sizeController = TextEditingController();
  final _costController = TextEditingController();
  String _breed = broilerBreeds.first['value']!;
  String _status = 'active';
  DateTime? _startDate = DateTime.now();
  bool _isLoading = false;
  String? _selectedFarmId;

  @override
  void initState() {
    super.initState();
    if (widget.batch != null) {
      _nameController.text = widget.batch!.name;
      _sizeController.text = widget.batch!.initialChicks.toString();
      _costController.text = widget.batch!.costPerChick.toString();
      _breed = widget.batch!.breed ?? broilerBreeds.first['value']!;
      _status = widget.batch!.status.toLowerCase();
      _startDate = widget.batch!.commencementDate;
      _selectedFarmId = widget.batch!.sourceLocation;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sizeController.dispose();
    _costController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.vibrate(); 
      return;
    }

    setState(() => _isLoading = true);
    final initialChicks = int.parse(_sizeController.text);
    final costPerChick = double.tryParse(_costController.text) ?? 0.0;

    final data = {
      'name': _nameController.text.trim(),
      'initial_count': initialChicks,
      'cost_per_bird': costPerChick,
      'total_acquisition_cost': initialChicks * costPerChick,
      'breed': _breed,
      'start_date': DateFormat('yyyy-MM-dd').format(_startDate!),
      'status': _status,
      'source_location': _selectedFarmId,
    };

    try {
      if (widget.batch != null) {
        await ApiClient.instance.put('${ApiEndpoints.batches}${widget.batch!.id}', data: data);
      } else {
        await ApiClient.instance.post(ApiEndpoints.batches, data: data);
      }

      if (mounted) {
        HapticFeedback.heavyImpact();
        ToastService.showSuccess(context, widget.batch != null ? 'Batch updated' : 'Batch created');
        ref.read(broilerProvider.notifier).fetchBatches();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        HapticFeedback.vibrate();
        String message = widget.batch != null ? 'Failed to update batch' : 'Failed to create batch';
        if (e is DioException) {
          message = getFriendlyErrorMessage(e);
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
        autovalidateMode: AutovalidateMode.onUserInteraction,
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
              ref.watch(farmsProvider).when(
                    data: (farms) {
                      if (farms.isEmpty) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedFarmId,
                          decoration: InputDecoration(
                            labelText: 'Farm / Location',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          items: farms
                              .map((f) => DropdownMenuItem(
                                    value: f['id'].toString(),
                                    child: Text(f['name']),
                                  ))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) {
                              HapticFeedback.selectionClick();
                              setState(() => _selectedFarmId = v);
                            }
                          },
                        ),
                      );
                    },
                    loading: () => const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Center(child: LinearProgressIndicator()),
                    ),
                    error: (e, s) => const SizedBox.shrink(),
                  ),
              CustomInput(
                label: 'Batch Name',
                hintText: 'e.g., Flock A - Q1',
                controller: _nameController,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomInput(
                      label: 'Initial Count',
                      hintText: 'e.g., 500',
                      controller: _sizeController,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        final count = int.tryParse(v);
                        if (count == null) return 'Invalid';
                        if (count <= 0) return '> 0';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomInput(
                      label: 'Cost per Chick',
                      hintText: 'e.g., 75',
                      controller: _costController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _breed,
                decoration: InputDecoration(
                  labelText: 'Breed',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: broilerBreeds
                    .map((b) => DropdownMenuItem(value: b['value'], child: Text(b['label']!)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    HapticFeedback.selectionClick();
                    setState(() => _breed = v);
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: ['active', 'completed', 'sold', 'culled']
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
                title: const Text('Commencement Date'),
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

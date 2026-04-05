import 'package:mobile/presentation/widgets/custom_divider.dart';
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
import '../../../../core/models/broiler_models.dart';
import '../../../../core/constants/broiler_constants.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';


class VaccinationsScreen extends ConsumerStatefulWidget {
  const VaccinationsScreen({super.key});

  @override
  ConsumerState<VaccinationsScreen> createState() => _VaccinationsScreenState();
}

class _VaccinationsScreenState extends ConsumerState<VaccinationsScreen> {
  String? _selectedBatchId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vaccAsync = ref.watch(vaccinationProvider);
    final profileAsync = ref.watch(profileProvider);
    final broilerState = ref.watch(broilerProvider);
    final currentBatch = broilerState.currentBatch;
    final canEdit = profileAsync.value?.canEdit ?? false;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Vaccinations', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(vaccinationProvider),
        child: vaccAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: $err'),
                ElevatedButton(onPressed: () => ref.invalidate(vaccinationProvider), child: const Text('Retry')),
              ],
            ),
          ),
          data: (records) {
            final filteredRecords = _selectedBatchId == null 
              ? records 
              : records.where((e) => e.batchId == _selectedBatchId).toList();
            final sortedRecords = List<VaccinationRecord>.from(filteredRecords)
              ..sort((a, b) => b.date.compareTo(a.date));

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
                              Text('Total Administered', style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(150), fontSize: 14)),
                              const SizedBox(height: 4),
                              Text('${sortedRecords.length} records', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                            ],
                          ),
                          Icon(LucideIcons.syringe, color: theme.colorScheme.primary, size: 40),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Records Overview',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (filteredRecords.isEmpty)
                      CustomCard(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Text(
                              'No past vaccination records found.',
                              style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(150)),
                            ),
                          ),
                        ),
                      )
                  else
                    ...sortedRecords.map((v) {
                         return Padding(
                           padding: const EdgeInsets.only(bottom: 12),
                           child: CustomCard(
                             isPremium: true,
                             child: ListTile(
                               contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                               leading: CircleAvatar(
                                 backgroundColor: theme.colorScheme.primary.withAlpha(25),
                                 child: Icon(LucideIcons.syringe, color: theme.colorScheme.primary),
                               ),
                               title: Text(v.vaccineName, style: const TextStyle(fontWeight: FontWeight.bold)),
                               subtitle: Text('Date: ${DateFormat('MMM dd, yyyy').format(v.date)} | Method: ${v.administrationMethod.replaceAll('_', ' ').toUpperCase()}'),
                               trailing: !canEdit ? null : PopupMenuButton<String>(
                                 icon: const Icon(LucideIcons.moreVertical),
                                 onSelected: (value) async {
                                   if (value == 'edit') {
                                     _showAddEditVaccinationDialog(context, ref, currentBatch, item: v);
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
                                         await ApiClient.instance.delete('${ApiEndpoints.vaccination}/${v.id}');
                                         ref.invalidate(vaccinationProvider);
                                       } catch (e) {
                                         if (context.mounted) {
                                           String message = 'Failed to delete';
                                           if (e is DioException && e.response?.statusCode == 404) {
                                             message = 'Record already deleted';
                                             ref.invalidate(vaccinationProvider);
                                           }
                                           ToastService.showError(context, message);
                                         }
                                       }
                                     }
                                   }
                                 },
                                 itemBuilder: (context) => [
                                   const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                   PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: theme.colorScheme.error))),
                                 ],
                               ),
                               onTap: () => _showVaccinationDetails(context, v),
                             ),
                           ),
                         );
                    }),
                ],
              ),
            );
          },
        ),
      ),
       floatingActionButton: canEdit ? FloatingActionButton(
        onPressed: () => _showAddEditVaccinationDialog(context, ref, currentBatch),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        child: const Icon(LucideIcons.plus),
      ) : null,
    );
  }

  void _showAddEditVaccinationDialog(BuildContext context, WidgetRef ref, Batch? currentBatch, {VaccinationRecord? item}) {
    showDialog(
      context: context,
      builder: (ctx) => _AddEditVaccinationDialog(currentBatch: currentBatch, item: item),
    );
  }

  void _showVaccinationDetails(BuildContext context, VaccinationRecord v) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(v.vaccineName),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow(context, 'Event Date', DateFormat('yyyy-MM-dd').format(v.date)),
              _detailRow(context, 'Method', v.administrationMethod.replaceAll('_', ' ').toUpperCase()),
              _detailRow(context, 'Cost', 'KES ${v.cost}'),
              const CustomDivider(),
              _detailRow(context, 'Dosage', v.dosage ?? 'Default'),
              if (v.scheduledDate != null)
                _detailRow(context, 'Scheduled Date', DateFormat('yyyy-MM-dd').format(v.scheduledDate!)),
              if (v.administeredBy?.isNotEmpty == true) _detailRow(context, 'Administered By', v.administeredBy!),
              if (v.batchNumber?.isNotEmpty == true) _detailRow(context, 'Vaccine Batch #', v.batchNumber!),
              _detailRow(context, 'Status', v.completed ? 'COMPLETED' : 'PENDING'),
              _detailRow(context, 'Notes', v.notes ?? 'No notes recorded'),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
      ),
    );
  }

  Widget _detailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

class _AddEditVaccinationDialog extends StatefulWidget {
  final Batch? currentBatch;
  final VaccinationRecord? item;

  const _AddEditVaccinationDialog({this.currentBatch, this.item});

  @override
  State<_AddEditVaccinationDialog> createState() => _AddEditVaccinationDialogState();
}

class _AddEditVaccinationDialogState extends State<_AddEditVaccinationDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _dosageController;
  late final TextEditingController _costController;
  late final TextEditingController _notesController;
  late final TextEditingController _diseaseController;
  late final TextEditingController _administeredByController;
  late final TextEditingController _batchNumberController;

  String _method = vaccinationMethods.first['value'] as String;
  bool _isLoading = false;
  bool _completed = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.vaccineName ?? '');
    _dosageController = TextEditingController(text: widget.item?.dosage ?? '');
    _costController = TextEditingController(text: widget.item?.cost?.toString() ?? '');
    _notesController = TextEditingController(text: widget.item?.notes ?? '');
    _diseaseController = TextEditingController(text: widget.item?.diseaseTarget ?? '');
    _administeredByController = TextEditingController(text: widget.item?.administeredBy ?? '');
    _batchNumberController = TextEditingController(text: widget.item?.batchNumber ?? '');
    _method = widget.item?.administrationMethod ?? vaccinationMethods.first['value'] as String;
    _completed = widget.item?.completed ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _costController.dispose();
    _notesController.dispose();
    _diseaseController.dispose();
    _administeredByController.dispose();
    _batchNumberController.dispose();
    super.dispose();
  }

  Future<void> _submit(WidgetRef ref) async {
    if (!_formKey.currentState!.validate()) return;

    final batchId = widget.item?.batchId ?? widget.currentBatch?.id;
    if (batchId == null) {
      if (mounted) ToastService.showError(context, 'No batch selected');
      return;
    }

    setState(() => _isLoading = true);
    final payload = {
      'event_id': const Uuid().v4(),
      'vaccine_name': _nameController.text.trim(),
      'disease_target': _diseaseController.text.trim(),
      'administration_method': _method,
      'dosage': _dosageController.text.trim().isEmpty ? null : _dosageController.text.trim(),
      'administered_by': _administeredByController.text.trim().isEmpty ? null : _administeredByController.text.trim(),
      'batch_number': _batchNumberController.text.trim().isEmpty ? null : _batchNumberController.text.trim(),
      'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    };

    try {
      if (widget.item != null) {
        await ApiClient.instance.put('${ApiEndpoints.vaccination}/${widget.item!.id}', data: payload);
      } else {
        await ApiClient.instance.post('${ApiEndpoints.vaccination}?flock_id=$batchId', data: payload);
      }

      if (mounted) {
        Navigator.pop(context);
        ref.invalidate(vaccinationProvider);
        ToastService.showSuccess(context, 'Vaccination saved successfully');
      }
    } catch (e) {
      if (mounted) ToastService.showError(context, 'Failed to save vaccination');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) => AlertDialog(
        title: Text(widget.item != null ? 'Edit Vaccination' : 'Log Vaccination'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text == '') {
                      return const Iterable<String>.empty();
                    }
                    return commonVaccines.where((String option) {
                      return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                    });
                  },
                  onSelected: (String selection) {
                    _nameController.text = selection;
                  },
                  fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                    controller.text = _nameController.text;
                    return CustomInput(
                      label: 'Vaccine Name',
                      hintText: 'e.g. Gumboro',
                      controller: controller,
                      focusNode: focusNode,
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                      onChanged: (v) => _nameController.text = v,
                    );
                  },
                ),
                const SizedBox(height: 12),
                CustomInput(
                  label: 'Disease Target',
                  hintText: 'e.g. Newcastle / Gumboro',
                  controller: _diseaseController,
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _method,
                  decoration: InputDecoration(
                    labelText: 'Administration Method',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: vaccinationMethods
                      .map((m) => DropdownMenuItem(value: m['value'] as String, child: Text(m['label'] as String)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _method = v);
                  },
                ),
                const SizedBox(height: 12),
                CustomInput(
                  label: 'Cost (KES, Optional)',
                  controller: _costController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 12),
                CustomInput(label: 'Dosage (Optional)', controller: _dosageController),
                const SizedBox(height: 12),
                CustomInput(label: 'Administered By (Optional)', controller: _administeredByController),
                const SizedBox(height: 12),
                CustomInput(label: 'Vaccine Batch Number (Optional)', controller: _batchNumberController),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Completed'),
                  value: _completed,
                  onChanged: (v) => setState(() => _completed = v),
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

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
import 'package:uuid/uuid.dart';
import 'package:dio/dio.dart';


class VaccinationsScreen extends ConsumerStatefulWidget {
  const VaccinationsScreen({super.key});

  @override
  ConsumerState<VaccinationsScreen> createState() => _VaccinationsScreenState();
}

class _VaccinationsScreenState extends ConsumerState<VaccinationsScreen> {
  String? _selectedBatchId;

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final theme = Theme.of(context);
    final vaccAsync = ref.watch(vaccinationProvider);
    final userAsync = ref.watch(profileProvider);
    final isViewer = userAsync.value?['role'] == 'VIEWER';
    final broilerState = ref.watch(broilerProvider);
    final currentBatch = broilerState.currentBatch;

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
              : records.where((e) => e['flock_id']?.toString() == _selectedBatchId).toList();
            final sortedRecords = List<dynamic>.from(filteredRecords)
              ..sort((a, b) {
                final dateA = DateTime.tryParse(a['event_date']?.toString() ?? '') ?? DateTime(2000);
                final dateB = DateTime.tryParse(b['event_date']?.toString() ?? '') ?? DateTime(2000);
                return dateB.compareTo(dateA);
              });
            
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String?>(
                    initialValue: _selectedBatchId,
                    decoration: InputDecoration(
                      labelText: 'Filter by Batch',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All Batches')),
                      ...broilerState.batches.map((b) => DropdownMenuItem(value: b['id']?.toString(), child: Text(b['name'] ?? 'Unknown'))),
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
                         final dateStr = v['event_date']?.toString() ?? DateTime.now().toIso8601String();
                         final date = DateTime.tryParse(dateStr) ?? DateTime.now();
                         
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
                               title: Text(v['vaccine_name'] ?? 'Unknown Vaccine', style: const TextStyle(fontWeight: FontWeight.bold)),
                               subtitle: Text('Date: ${DateFormat('MMM dd, yyyy').format(date)} | Method: ${(v['administration_method'] ?? 'Standard').replaceAll('_', ' ').toUpperCase()}'),
                               trailing: isViewer ? null : PopupMenuButton<String>(
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
                                           TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                                         ],
                                       ),
                                     );
                                     if (confirm == true) {
                                       try {

                                         await ApiClient.instance.delete('${ApiEndpoints.vaccination}/${v['id']}');

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
                                 itemBuilder: (context) => const [
                                   PopupMenuItem(value: 'edit', child: Text('Edit')),
                                   PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
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
      floatingActionButton: isViewer ? null : FloatingActionButton(
        onPressed: () => _showAddEditVaccinationDialog(context, ref, currentBatch),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(LucideIcons.plus),
      ),
    );
  }

  void _showAddEditVaccinationDialog(BuildContext context, WidgetRef ref, Map<String, dynamic>? currentBatch, {Map<String, dynamic>? item}) {
    showDialog(
      context: context,
      builder: (ctx) => _AddEditVaccinationDialog(currentBatch: currentBatch, item: item),
    );
  }

  void _showVaccinationDetails(BuildContext context, Map<String, dynamic> v) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(v['vaccine_name'] ?? 'Vaccination'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('Event Date', v['event_date']?.toString().split('T').first ?? 'N/A'),
              _detailRow('Disease Target', v['disease_target'] ?? 'N/A'),
              _detailRow('Method', (v['administration_method'] ?? 'N/A').toString().replaceAll('_', ' ').toUpperCase()),
              const CustomDivider(),
              _detailRow('Dosage', v['dosage']?.toString() ?? 'Default'),
              _detailRow('Administered By', v['administered_by'] ?? 'Unassigned'),
              _detailRow('Batch Number', v['batch_number'] ?? 'N/A'),
              if (v['next_due_date'] != null)
                _detailRow('Next due', v['next_due_date']?.toString().split('T').first ?? ''),
              _detailRow('Notes', v['notes'] ?? 'No notes recorded'),
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

class _AddEditVaccinationDialog extends StatefulWidget {
  final Map<String, dynamic>? currentBatch;
  final Map<String, dynamic>? item;

  const _AddEditVaccinationDialog({this.currentBatch, this.item});

  @override
  State<_AddEditVaccinationDialog> createState() => _AddEditVaccinationDialogState();
}

class _AddEditVaccinationDialogState extends State<_AddEditVaccinationDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _targetController;
  late final TextEditingController _dosageController;
  late final TextEditingController _adminByController;
  late final TextEditingController _notesController;

  String _method = 'drinking_water';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?['vaccine_name'] ?? '');
    _targetController = TextEditingController(text: widget.item?['disease_target'] ?? '');
    _dosageController = TextEditingController(text: widget.item?['dosage'] ?? '');
    _adminByController = TextEditingController(text: widget.item?['administered_by'] ?? '');
    _notesController = TextEditingController(text: widget.item?['notes'] ?? '');
    _method = widget.item?['administration_method'] ?? 'drinking_water';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _dosageController.dispose();
    _adminByController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit(WidgetRef ref) async {
    if (!_formKey.currentState!.validate()) return;

    final batchId = widget.item?['flock_id'] ?? widget.currentBatch?['id'];
    if (batchId == null) {
      if (mounted) ToastService.showError(context, 'No batch selected');
      return;
    }

    setState(() => _isLoading = true);
    final payload = {
      'vaccine_name': _nameController.text.trim(),
      'disease_target': _targetController.text.trim(),
      'administration_method': _method,
      'dosage': _dosageController.text.trim().isEmpty ? null : _dosageController.text.trim(),
      'administered_by': _adminByController.text.trim().isEmpty ? null : _adminByController.text.trim(),
      'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    };

    try {
      if (widget.item != null) {
        await ApiClient.instance.put('${ApiEndpoints.vaccination}/${widget.item!['id']}', data: payload);
      } else {
        payload['event_id'] = const Uuid().v4();
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
                CustomInput(
                  label: 'Vaccine Name',
                  hintText: 'e.g. Gumboro',
                  controller: _nameController,
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                CustomInput(
                  label: 'Disease Target',
                  hintText: 'e.g. Newcastle',
                  controller: _targetController,
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _method,
                  decoration: InputDecoration(
                    labelText: 'Administration Method',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'drinking_water', child: Text('Drinking Water')),
                    DropdownMenuItem(value: 'eye_drop', child: Text('Eye Drop')),
                    DropdownMenuItem(value: 'injection', child: Text('Injection')),
                    DropdownMenuItem(value: 'spray', child: Text('Spray')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _method = v);
                  },
                ),
                const SizedBox(height: 12),
                CustomInput(label: 'Dosage (Optional)', controller: _dosageController),
                const SizedBox(height: 12),
                CustomInput(label: 'Administered By (Optional)', controller: _adminByController),
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

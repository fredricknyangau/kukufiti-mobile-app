import 'package:mobile/shared/widgets/custom_divider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:mobile/shared/widgets/app_drawer.dart';
import 'package:mobile/shared/widgets/custom_card.dart';
import 'package:mobile/shared/widgets/custom_input.dart';
import 'package:mobile/shared/widgets/custom_button.dart';
import 'package:mobile/shared/providers/data_providers.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/api_endpoints.dart';
import 'package:mobile/core/utils/toast_service.dart';
import 'package:mobile/core/models/broiler_models.dart';
import 'package:intl/intl.dart';

class VetScreen extends ConsumerWidget {
  const VetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final vetAsync = ref.watch(vetConsultationsProvider);
    final profileAsync = ref.watch(profileProvider);
    final user = profileAsync.value;
    final canEdit = user?.canEdit ?? false;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Veterinary Consults', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomCard(
               isPremium: true,
               child: ListTile(
                 contentPadding: EdgeInsets.zero,
                 leading: Icon(LucideIcons.stethoscope, color: theme.colorScheme.primary, size: 36),
                 title: const Text('Dr. John Doe', style: TextStyle(fontWeight: FontWeight.bold)),
                 subtitle: const Text('Available inside hours • Tap to contact'),
                 trailing: const Icon(LucideIcons.phone),
                 onTap: () {
                   // launch phone dialer
                 },
               )
            ),
            const SizedBox(height: 24),
            Text(
              'Visit Logs & Symptoms',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            vetAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (consults) {
                if (consults.isEmpty) {
                  return CustomCard(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          'No vet consultation records available.',
                          style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(150)),
                        ),
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: consults.length,
                  itemBuilder: (context, index) {
                    final consult = consults[index];
                    return CustomCard(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const Icon(LucideIcons.fileText),
                        title: Text(consult.issue, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(DateFormat('MMM dd, yyyy').format(consult.date)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withAlpha(25),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                consult.status.toUpperCase(),
                                style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                            ),
                            if (canEdit)
                              PopupMenuButton<String>(
                                icon: const Icon(LucideIcons.moreVertical, size: 20),
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _showAddEditConsultationDialog(context, ref, item: consult);
                                  }
                                },
                                itemBuilder: (context) => const [
                                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                                ],
                              ),
                          ],
                        ),
                        onTap: () => _showConsultationDetails(context, consult),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: canEdit
          ? FloatingActionButton(
              onPressed: () => _showAddEditConsultationDialog(context, ref),
              backgroundColor: theme.colorScheme.primary,
              child: const Icon(LucideIcons.plus),
            )
          : null,
    );
  }
  void _showAddEditConsultationDialog(BuildContext context, WidgetRef ref, {VetConsultation? item}) {
    showDialog(
      context: context,
      builder: (ctx) => _AddEditConsultationDialog(item: item),
    );
  }

  void _showConsultationDetails(BuildContext context, VetConsultation consult) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(consult.issue),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow(context, 'Date', DateFormat('yyyy-MM-dd').format(consult.date)),
              _detailRow(context, 'Status', consult.status.toUpperCase()),
              const CustomDivider(),
              if (consult.symptoms?.isNotEmpty == true) _detailRow(context, 'Symptoms', consult.symptoms!),
              _detailRow(context, 'Diagnosis', consult.diagnosis?.isNotEmpty == true ? consult.diagnosis! : 'None Recorded'),
              const CustomDivider(),
              _detailRow(context, 'Treatment / Rec', consult.treatment?.isNotEmpty == true ? consult.treatment! : 'None Recorded'),
              const CustomDivider(),
              _detailRow(context, 'Vet Name', consult.vetName ?? 'Not Assigned'),
              if (consult.vetPhone?.isNotEmpty == true) _detailRow(context, 'Vet Phone', consult.vetPhone!),
              const CustomDivider(),
              _detailRow(context, 'Notes', consult.notes?.isNotEmpty == true ? consult.notes! : 'No Notes'),
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

class _AddEditConsultationDialog extends StatefulWidget {
  final VetConsultation? item;

  const _AddEditConsultationDialog({this.item});

  @override
  State<_AddEditConsultationDialog> createState() => _AddEditConsultationDialogState();
}

class _AddEditConsultationDialogState extends State<_AddEditConsultationDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _reasonController;
  late final TextEditingController _symptomsController;
  late final TextEditingController _diagnosisController;
  late final TextEditingController _treatmentController;
  late final TextEditingController _vetNameController;
  late final TextEditingController _vetPhoneController;
  late final TextEditingController _notesController;

  String _status = 'pending';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _reasonController = TextEditingController(text: widget.item?.issue ?? '');
    _symptomsController = TextEditingController(text: widget.item?.symptoms ?? '');
    _diagnosisController = TextEditingController(text: widget.item?.diagnosis ?? '');
    _treatmentController = TextEditingController(text: widget.item?.treatment ?? '');
    _vetNameController = TextEditingController(text: widget.item?.vetName ?? '');
    _vetPhoneController = TextEditingController(text: widget.item?.vetPhone ?? '');
    _notesController = TextEditingController(text: widget.item?.notes ?? '');
    _status = widget.item?.status ?? 'pending';
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _symptomsController.dispose();
    _diagnosisController.dispose();
    _treatmentController.dispose();
    _vetNameController.dispose();
    _vetPhoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit(WidgetRef ref) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final payload = {
      'issue': _reasonController.text.trim(),
      'symptoms': _symptomsController.text.trim().isEmpty ? null : _symptomsController.text.trim(),
      'diagnosis': _diagnosisController.text.trim().isEmpty ? null : _diagnosisController.text.trim(),
      'treatment': _treatmentController.text.trim().isEmpty ? null : _treatmentController.text.trim(),
      'vet_name': _vetNameController.text.trim().isEmpty ? null : _vetNameController.text.trim(),
      'vet_phone': _vetPhoneController.text.trim().isEmpty ? null : _vetPhoneController.text.trim(),
      'date': widget.item?.date != null ? DateFormat('yyyy-MM-dd HH:mm:ss').format(widget.item!.date) : DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      'status': _status,
      'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    };

    try {
      if (widget.item != null) {
        await ApiClient.instance.put('${ApiEndpoints.vetConsultations}/${widget.item!.id}', data: payload);
      } else {
        await ApiClient.instance.post(ApiEndpoints.vetConsultations, data: payload);
      }
      if (mounted) {
        Navigator.pop(context);
        ref.invalidate(vetConsultationsProvider);
        ToastService.showSuccess(context, 'Consultation saved successfully');
      }
    } catch (e) {
      if (mounted) ToastService.showError(context, 'Failed to save consultation');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) => AlertDialog(
        title: Text(widget.item != null ? 'Edit Consultation' : 'Log Consultation'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomInput(
                  label: 'Issue Title',
                  hintText: 'e.g. Coughing Flock',
                  controller: _reasonController,
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                CustomInput(
                  label: 'Symptoms observed (Optional)',
                  hintText: 'e.g. Lethargy, drooping wings',
                  controller: _symptomsController,
                ),
                const SizedBox(height: 12),
                CustomInput(label: 'Diagnosis (Optional)', controller: _diagnosisController),
                const SizedBox(height: 12),
                CustomInput(
                  label: 'Treatment / Recommendation',
                  hintText: 'e.g. Antibiotics',
                  controller: _treatmentController,
                ),
                const SizedBox(height: 12),
                CustomInput(label: 'Vet Name (Optional)', controller: _vetNameController),
                const SizedBox(height: 12),
                CustomInput(label: 'Vet Phone (Optional)', controller: _vetPhoneController, keyboardType: TextInputType.phone),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _status,
                  decoration: InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: ['pending', 'in_progress', 'resolved']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s.replaceAll('_', ' ').toUpperCase())))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _status = v);
                  },
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

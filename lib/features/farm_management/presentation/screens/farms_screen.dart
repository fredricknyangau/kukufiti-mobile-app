import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/utils/toast_service.dart';
import '../../../../providers/data_providers.dart';
import '../../../../presentation/widgets/app_drawer.dart';
import '../../../../presentation/widgets/custom_card.dart';
import '../../../../presentation/widgets/custom_input.dart';
import '../../../../presentation/widgets/custom_button.dart';
// Removed unused custom_divider.dart import

class FarmsScreen extends ConsumerWidget {
  const FarmsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final farmsAsync = ref.watch(farmsProvider);
    final theme = Theme.of(context);
    final profileAsync = ref.watch(profileProvider);
    final user = profileAsync.value;
    final canEdit = user?.canEdit ?? false;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Manage Farms', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(farmsProvider.future),
        child: farmsAsync.when(
          data: (farms) {
            if (farms.isEmpty) {
              return ListView(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  Center(
                    child: Text(
                      'No farms found.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: farms.length,
              itemBuilder: (context, index) {
                final farm = farms[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CustomCard(
                    isPremium: true,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(LucideIcons.home, color: theme.colorScheme.primary),
                      ),
                      title: Text(
                        farm['name'] ?? 'Unnamed Farm',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Text(
                        farm['location'] ?? 'No location provided',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          fontSize: 13,
                        ),
                      ),
                      trailing: canEdit
                          ? PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _showAddFarmSheet(context, ref, farm: farm);
                                } else if (value == 'delete') {
                                  _confirmDelete(context, ref, farm);
                                }
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(value: 'edit', child: Text('Edit')),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            )
                          : null,
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => ListView(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.3),
              Center(
                child: Text(
                  'Error: $err',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: canEdit
          ? FloatingActionButton(
              heroTag: null,
              onPressed: () {
                HapticFeedback.lightImpact();
                _showAddFarmSheet(context, ref);
              },
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              child: const Icon(LucideIcons.plus),
            )
          : null,
    );
  }

  void _showAddFarmSheet(BuildContext context, WidgetRef ref, {Map<String, dynamic>? farm}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _AddFarmSheet(farm: farm),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Map<String, dynamic> farm) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Farm?'),
        content: Text('Are you sure you want to delete ${farm['name']}? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.pop(context, true);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ApiClient.instance.delete('${ApiEndpoints.farms}${farm['id']}');
        ref.invalidate(farmsProvider);
        if (context.mounted) ToastService.showSuccess(context, 'Farm deleted');
      } catch (e) {
        if (context.mounted) ToastService.showError(context, 'Failed to delete: $e');
      }
    }
  }
}

class _AddFarmSheet extends ConsumerStatefulWidget {
  final Map<String, dynamic>? farm;

  const _AddFarmSheet({this.farm});

  @override
  ConsumerState<_AddFarmSheet> createState() => _AddFarmSheetState();
}

class _AddFarmSheetState extends ConsumerState<_AddFarmSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.farm != null) {
      _nameController.text = widget.farm!['name'] ?? '';
      _locationController.text = widget.farm!['location'] ?? '';
      _isActive = widget.farm!['is_active'] ?? true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.vibrate();
      return;
    }

    setState(() => _isLoading = true);
    final data = {
      'name': _nameController.text.trim(),
      'location': _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
      'is_active': _isActive,
    };

    try {
      if (widget.farm != null) {
        await ApiClient.instance.put('${ApiEndpoints.farms}${widget.farm!['id']}', data: data);
      } else {
        await ApiClient.instance.post(ApiEndpoints.farms, data: data);
      }

      if (mounted) {
        HapticFeedback.heavyImpact();
        ToastService.showSuccess(context, widget.farm != null ? 'Farm updated' : 'Farm created');
        ref.invalidate(farmsProvider);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        HapticFeedback.vibrate();
        String message = widget.farm != null ? 'Failed to update farm' : 'Failed to create farm';
        if (e is DioException && e.response?.data is Map) {
          message = e.response!.data['detail'] ?? message;
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
                widget.farm != null ? 'Edit Farm' : 'Add New Farm',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              CustomInput(
                label: 'Farm Name',
                hintText: 'e.g., Main Layout / East Wing',
                controller: _nameController,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              CustomInput(
                label: 'Location (Optional)',
                hintText: 'e.g., Nakuru, Pipeline',
                controller: _locationController,
              ),
              if (ref.watch(profileProvider).value?.isAdmin ?? false) ...[
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Active Farm'),
                  subtitle: const Text('Is this farm currently operational?'),
                  value: _isActive,
                  onChanged: (v) {
                    HapticFeedback.selectionClick();
                    setState(() => _isActive = v);
                  },
                ),
              ],
              const SizedBox(height: 32),
              CustomButton(
                text: widget.farm != null ? 'Update Farm' : 'Create Farm',
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

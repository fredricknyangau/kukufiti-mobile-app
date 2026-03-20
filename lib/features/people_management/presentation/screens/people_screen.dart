import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../presentation/widgets/app_drawer.dart';
import '../../../../presentation/widgets/custom_button.dart';
import '../../../../presentation/widgets/custom_card.dart';
import '../../../../presentation/widgets/custom_input.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/utils/toast_service.dart';
import '../../../../providers/data_providers.dart';

class PeopleScreen extends StatelessWidget {
  const PeopleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        drawer: const AppDrawer(),
        appBar: AppBar(
          title: const Text('People Management', style: TextStyle(fontWeight: FontWeight.bold)),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Suppliers'),
              Tab(text: 'Customers'),
              Tab(text: 'Employees'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _PeopleList(type: 'Supplier'),
            _PeopleList(type: 'Customer'),
            _PeopleList(type: 'Employee'),
          ],
        ),
        floatingActionButton: Consumer(
          builder: (context, ref, child) {
            return FloatingActionButton(
              onPressed: () => _showAddPersonSheet(context, ref),
              child: const Icon(LucideIcons.userPlus),
            );
          },
        ),
      ),
    );
  }

}

void _showAddPersonSheet(BuildContext context, WidgetRef ref, {Map<String, dynamic>? item, String? initialType}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => _AddPersonSheet(ref: ref, item: item, initialType: initialType),
  );
}

class _AddPersonSheet extends StatefulWidget {
  final WidgetRef ref;
  final Map<String, dynamic>? item;
  final String? initialType;

  const _AddPersonSheet({required this.ref, this.item, this.initialType});

  @override
  State<_AddPersonSheet> createState() => _AddPersonSheetState();
}

class _AddPersonSheetState extends State<_AddPersonSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedType = 'Supplier';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _nameController.text = widget.item!['name'] ?? '';
      _emailController.text = widget.item!['email'] ?? '';
      _phoneController.text = widget.item!['phone_number'] ?? widget.item!['phone'] ?? '';
    }
    if (widget.initialType != null) {
      _selectedType = widget.initialType!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final endpointType = '${_selectedType.toLowerCase()}s';
      final payload = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone_number': _phoneController.text.trim(),
      };

      if (widget.item != null) {
        await ApiClient.instance.put('${ApiEndpoints.people(endpointType)}/${widget.item!['id']}', data: payload);
      } else {
        await ApiClient.instance.post(ApiEndpoints.people(endpointType), data: payload);
      }

      if (mounted) {
        ToastService.showSuccess(context, '$_selectedType ${widget.item != null ? 'updated' : 'added'} successfully');
        widget.ref.invalidate(peopleProvider(endpointType));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ToastService.showError(context, 'Failed to add person: $e');
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.item != null ? 'Edit Person Details' : 'Add New Person',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              initialValue: _selectedType,
              decoration: InputDecoration(
                labelText: 'Role Type',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: ['Supplier', 'Customer', 'Employee']
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedType = v);
              },
            ),
            const SizedBox(height: 16),
            CustomInput(
              label: 'Full Name *',
              hintText: 'e.g. John Doe',
              controller: _nameController,
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            CustomInput(
              label: 'Phone Number',
              hintText: 'e.g. +254...',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              validator: (v) {
                if (v == null || v.isEmpty) return null;
                if (!RegExp(r'^\+?[0-9]{9,15}$').hasMatch(v.replaceAll(' ', ''))) {
                  return 'Enter valid phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomInput(
              label: 'Email Address',
              hintText: 'e.g. john@example.com',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return null;
                if (!v.contains('@') || !v.contains('.')) return 'Enter valid email';
                return null;
              },
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Save Details',
              onPressed: _submit,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}

class _PeopleList extends ConsumerStatefulWidget {
  final String type;
  const _PeopleList({required this.type});

  @override
  ConsumerState<_PeopleList> createState() => _PeopleListState();
}

class _PeopleListState extends ConsumerState<_PeopleList> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final endpointType = '${widget.type.toLowerCase()}s';
    final asyncPeople = ref.watch(peopleProvider(endpointType));

    return asyncPeople.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
      data: (people) {
        final filteredPeople = people.where((person) {
          final name = (person['name'] ?? '').toString().toLowerCase();
          final contact = (person['phone'] ?? person['email'] ?? '').toString().toLowerCase();
          return name.contains(_searchQuery.toLowerCase()) || contact.contains(_searchQuery.toLowerCase());
        }).toList();

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(peopleProvider(endpointType));
          },
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: CustomInput(
                  label: '',
                  hintText: 'Search ${widget.type.toLowerCase()}s...',
                  prefixIcon: Icon(LucideIcons.search, size: 20, color: theme.colorScheme.primary),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
              if (filteredPeople.isEmpty)
                Expanded(child: Center(child: Text('No ${widget.type.toLowerCase()}s match search.')))
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredPeople.length,
                    itemBuilder: (context, index) {
                      final person = filteredPeople[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: CustomCard(
                          isPremium: true,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            leading: CircleAvatar(
                              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                              child: Icon(LucideIcons.user, color: theme.colorScheme.primary),
                            ),
                            title: Text(person['name'] ?? 'Unknown Name', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(person['phone_number'] ?? person['phone'] ?? person['email'] ?? 'No contact info'),
                            trailing: PopupMenuButton<String>(
                              icon: const Icon(LucideIcons.moreVertical, size: 20),
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              onSelected: (value) async {
                                if (value == 'edit') {
                                  _showAddPersonSheet(context, ref, item: person, initialType: widget.type);
                                } else if (value == 'delete') {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: Text('Delete ${widget.type}?'),
                                      content: const Text('This action cannot be undone.'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    try {
                                      await ApiClient.instance.delete('${ApiEndpoints.people(endpointType)}/${person['id']}');
                                      ref.invalidate(peopleProvider(endpointType));
                                    } catch (e) {
                                      if (context.mounted) ToastService.showError(context, 'Failed to delete');
                                    }
                                  }
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

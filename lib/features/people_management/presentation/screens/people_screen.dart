import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../presentation/widgets/app_drawer.dart';
import '../../../../presentation/widgets/custom_button.dart';
import '../../../../presentation/widgets/custom_card.dart';
import '../../../../presentation/widgets/custom_input.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/utils/toast_service.dart';
import '../../../../providers/data_providers.dart';
import '../../../../core/models/people_models.dart';

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
            dividerColor: Colors.transparent,
            tabs: [
              Tab(text: 'Suppliers'),
              Tab(text: 'Customers'),
              Tab(text: 'Employees'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _PeopleList<Supplier>(type: 'Supplier'),
            _PeopleList<Customer>(type: 'Customer'),
            _PeopleList<Employee>(type: 'Employee'),
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

void _showAddPersonSheet(BuildContext context, WidgetRef ref, {dynamic item, String? initialType}) {
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
  final dynamic item;
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
  final _notesController = TextEditingController();
  
  final _contactNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _salaryController = TextEditingController();
  
  String _selectedType = 'Supplier';
  String _category = 'feed';
  String _customerType = 'retail';
  String _employeeRole = 'worker';
  bool _isActive = true;
  DateTime _startDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _nameController.text = widget.item.name;
      _emailController.text = widget.item.email ?? '';
      _phoneController.text = widget.item.phoneNumber ?? '';
      
      if (widget.item is Supplier) {
        _selectedType = 'Supplier';
        _contactNameController.text = widget.item.contactName ?? '';
        _category = widget.item.category;
        _notesController.text = widget.item.notes ?? '';
      } else if (widget.item is Customer) {
        _selectedType = 'Customer';
        _locationController.text = widget.item.location ?? '';
        _customerType = widget.item.customerType;
        _notesController.text = widget.item.notes ?? '';
      } else if (widget.item is Employee) {
        _selectedType = 'Employee';
        _employeeRole = widget.item.role;
        _salaryController.text = widget.item.salary?.toString() ?? '';
        _isActive = widget.item.isActive;
        _startDate = widget.item.startDate ?? DateTime.now();
      }
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
    _notesController.dispose();
    _contactNameController.dispose();
    _locationController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final endpointType = '${_selectedType.toLowerCase()}s';
      final Map<String, dynamic> payload = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        'phone_number': _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      };

      if (_selectedType == 'Supplier') {
        payload['contact_name'] = _contactNameController.text.trim();
        payload['category'] = _category;
        payload['notes'] = _notesController.text.trim();
      } else if (_selectedType == 'Customer') {
        payload['location'] = _locationController.text.trim();
        payload['customer_type'] = _customerType;
        payload['notes'] = _notesController.text.trim();
      } else if (_selectedType == 'Employee') {
        payload['role'] = _employeeRole;
        payload['salary'] = double.tryParse(_salaryController.text) ?? 0.0;
        payload['is_active'] = _isActive;
        payload['start_date'] = DateFormat('yyyy-MM-dd').format(_startDate);
      }

      if (widget.item != null) {
        await ApiClient.instance.put('${ApiEndpoints.people(endpointType)}/${widget.item.id}', data: payload);
      } else {
        await ApiClient.instance.post(ApiEndpoints.people(endpointType), data: payload);
      }

      if (mounted) {
        ToastService.showSuccess(context, '$_selectedType ${widget.item != null ? 'updated' : 'added'} successfully');
        if (_selectedType == 'Supplier') widget.ref.invalidate(suppliersProvider);
        if (_selectedType == 'Customer') widget.ref.invalidate(customersProvider);
        if (_selectedType == 'Employee') widget.ref.invalidate(employeesProvider);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ToastService.showError(context, 'Failed to save person: $e');
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
        child: SingleChildScrollView(
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
              if (widget.item == null)
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
              ),
              const SizedBox(height: 16),
              CustomInput(
                label: 'Email Address',
                hintText: 'e.g. john@example.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              
              if (_selectedType == 'Supplier') ...[
                const SizedBox(height: 16),
                CustomInput(label: 'Contact Person', controller: _contactNameController),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                  items: ['feed', 'chicks', 'medicine', 'equipment', 'other']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c.toUpperCase())))
                      .toList(),
                  onChanged: (v) => setState(() => _category = v!),
                ),
              ],
              
              if (_selectedType == 'Customer') ...[
                const SizedBox(height: 16),
                CustomInput(label: 'Location', controller: _locationController),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _customerType,
                  decoration: const InputDecoration(labelText: 'Customer Type', border: OutlineInputBorder()),
                  items: ['wholesale', 'retail', 'other']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c.toUpperCase())))
                      .toList(),
                  onChanged: (v) => setState(() => _customerType = v!),
                ),
              ],
              
              if (_selectedType == 'Employee') ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _employeeRole,
                  decoration: const InputDecoration(labelText: 'Role', border: OutlineInputBorder()),
                  items: ['manager', 'worker', 'vet', 'other']
                      .map((r) => DropdownMenuItem(value: r, child: Text(r.toUpperCase())))
                      .toList(),
                  onChanged: (v) => setState(() => _employeeRole = v!),
                ),
                const SizedBox(height: 16),
                CustomInput(label: 'Salary (KES)', controller: _salaryController, keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Active Status'),
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                ),
              ],

              const SizedBox(height: 16),
              CustomInput(label: 'Notes', controller: _notesController, maxLines: 2),

              const SizedBox(height: 32),
              CustomButton(
                text: 'Save Details',
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

class _PeopleList<T> extends ConsumerStatefulWidget {
  final String type;
  const _PeopleList({required this.type});

  @override
  ConsumerState<_PeopleList<T>> createState() => _PeopleListState<T>();
}

class _PeopleListState<T> extends ConsumerState<_PeopleList<T>> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final endpointType = '${widget.type.toLowerCase()}s';
    
    late final AsyncValue<List<dynamic>> asyncPeople;
    if (T == Supplier) {
      asyncPeople = ref.watch(suppliersProvider);
    } else if (T == Customer) {
      asyncPeople = ref.watch(customersProvider);
    } else {
      asyncPeople = ref.watch(employeesProvider);
    }

    return asyncPeople.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
      data: (people) {
        final filteredPeople = people.where((person) {
          final name = person.name.toLowerCase();
          final contact = (person.phoneNumber ?? person.email ?? '').toLowerCase();
          return name.contains(_searchQuery.toLowerCase()) || contact.contains(_searchQuery.toLowerCase());
        }).toList();

        return RefreshIndicator(
          onRefresh: () async {
            if (T == Supplier) ref.invalidate(suppliersProvider);
            if (T == Customer) ref.invalidate(customersProvider);
            if (T == Employee) ref.invalidate(employeesProvider);
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
                Expanded(
                  child: Center(
                    child: Text(
                      _searchQuery.isEmpty
                          ? 'No ${widget.type.toLowerCase()}s yet. Tap the + to add one.'
                          : 'No ${widget.type.toLowerCase()}s match search.',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredPeople.length,
                    itemBuilder: (context, index) {
                      final person = filteredPeople[index];
                      String subtitle = person.phoneNumber ?? person.email ?? 'No contact info';
                      
                      if (person is Supplier) subtitle += ' | ${person.category.toUpperCase()}';
                      if (person is Customer) subtitle += ' | ${person.customerType.toUpperCase()}';
                      if (person is Employee) subtitle += ' | ${person.role.toUpperCase()}';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: CustomCard(
                          isPremium: true,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(LucideIcons.user, color: theme.colorScheme.primary, size: 24),
                            ),
                            title: Text(person.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(subtitle, style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                            ),
                            trailing: PopupMenuButton<String>(
                              icon: const Icon(LucideIcons.moreVertical, size: 20),
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
                                      await ApiClient.instance.delete('${ApiEndpoints.people(endpointType)}/${person.id}');
                                      if (T == Supplier) ref.invalidate(suppliersProvider);
                                      if (T == Customer) ref.invalidate(customersProvider);
                                      if (T == Employee) ref.invalidate(employeesProvider);
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
                      ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1, end: 0);
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

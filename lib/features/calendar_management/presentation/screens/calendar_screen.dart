import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../presentation/widgets/app_drawer.dart';
import '../../../../presentation/widgets/custom_card.dart';
import '../../../../providers/data_providers.dart';
import '../../../../providers/broiler_provider.dart';
import '../../../../core/models/broiler_models.dart';
import '../../../../core/network/api_client.dart';
import 'package:flutter/services.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();

    final mortalityAsync = ref.watch(mortalityProvider);
    final feedAsync = ref.watch(feedProvider);
    final vaccinationAsync = ref.watch(vaccinationProvider);
    final weightAsync = ref.watch(weightProvider);
    final tasksAsync = ref.watch(tasksProvider);

    if (mortalityAsync.isLoading || feedAsync.isLoading || vaccinationAsync.isLoading || weightAsync.isLoading || tasksAsync.isLoading) {
      return Scaffold(
        drawer: const AppDrawer(),
        appBar: AppBar(title: const Text('Calendar')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final allEvents = <Map<String, dynamic>>[];
    
    // Aggregate Mortality
    final List<MortalityRecord> mortalities = mortalityAsync.value ?? [];
    for (final e in mortalities) {
      allEvents.add({
        'type': 'mortality',
        'date': e.date,
        'title': 'Mortality: ${e.count} birds',
        'description': e.notes ?? '',
        'icon': LucideIcons.skull,
        'color': theme.colorScheme.error,
      });
    }
    
    // Aggregate Feed
    final List<FeedRecord> feeds = feedAsync.value ?? [];
    for (final e in feeds) {
      allEvents.add({
        'type': 'feed',
        'date': e.date,
        'title': 'Feed: ${e.quantity} kg',
        'description': e.feedType,
        'icon': LucideIcons.wheat,
        'color': Colors.blue,
      });
    }
    
    // Aggregate Vaccination
    final List<VaccinationRecord> vaccinations = vaccinationAsync.value ?? [];
    for (final e in vaccinations) {
      allEvents.add({
        'type': 'vaccination',
        'date': e.date,
        'title': 'Vaccine: ${e.vaccineName}',
        'description': e.administrationMethod.replaceAll('_', ' ').toUpperCase(),
        'icon': LucideIcons.syringe,
        'color': Colors.purple,
      });
    }
    
    // Aggregate Weight
    final List<WeightRecord> weights = weightAsync.value ?? [];
    for (final e in weights) {
      allEvents.add({
        'type': 'weight',
        'date': e.date,
        'title': 'Weight Check: ${e.averageWeight}g',
        'description': e.notes ?? '',
        'icon': LucideIcons.scale,
        'color': Colors.green,
      });
    }

    // Aggregate Tasks
    for (final e in tasksAsync.value ?? []) {
      if (e['due_date'] != null) {
        allEvents.add({
          'type': 'task',
          'date': DateTime.parse(e['due_date']),
          'title': e['title'] ?? 'Task',
          'description': e['description'] ?? '',
          'icon': LucideIcons.calendarCheck2,
          'color': Colors.orange,
        });
      }
    }

    final selectedDateEvents = allEvents.where((e) {
      final evtDate = e['date'] as DateTime;
      return evtDate.year == _selectedDate.year &&
             evtDate.month == _selectedDate.month &&
             evtDate.day == _selectedDate.day;
    }).toList();

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Calendar', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plus),
            onPressed: () {
              HapticFeedback.lightImpact();
              _showAddTaskSheet(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomCard(
              isPremium: true,
              child: CalendarDatePicker(
                initialDate: _selectedDate,
                firstDate: now.subtract(const Duration(days: 365)),
                lastDate: now.add(const Duration(days: 365)),
                onDateChanged: (date) {
                  setState(() => _selectedDate = date);
                },
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '${DateFormat('MMMM d, yyyy').format(_selectedDate)} Events',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (selectedDateEvents.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text(
                    'No events scheduled for this day.',
                    style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                  ),
                ),
              )
            else
              ...selectedDateEvents.map((evt) {
                final isTask = evt['type'] == 'task';
                final isDone = evt['status'] == 'DONE';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CustomCard(
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (evt['color'] as Color).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(evt['icon'] as IconData, color: evt['color'] as Color),
                      ),
                      title: Text(
                        evt['title'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: isDone ? TextDecoration.lineThrough : null,
                          color: isDone ? Colors.grey : null,
                        ),
                      ),
                      subtitle: evt['description'].toString().isNotEmpty
                          ? Text(evt['description'] as String)
                          : null,
                      trailing: isTask
                          ? Checkbox(
                              value: isDone,
                              activeColor: Colors.orange,
                              onChanged: (v) async {
                                HapticFeedback.selectionClick();
                                final messenger = ScaffoldMessenger.of(context);
                                try {
                                  final taskId = evt['id'];
                                  await ApiClient.instance.put('/tasks/$taskId', data: {
                                    'status': v == true ? 'DONE' : 'PENDING',
                                  });
                                  ref.invalidate(tasksProvider);
                                } catch (e) {
                                  if (mounted) {
                                    messenger.showSnackBar(
                                      SnackBar(content: Text('Error: $e')),
                                    );
                                  }
                                }
                              },
                            )
                          : null,
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  void _showAddTaskSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddTaskSheet(initialDate: _selectedDate),
    );
  }
}

class _AddTaskSheet extends ConsumerStatefulWidget {
  final DateTime initialDate;
  const _AddTaskSheet({required this.initialDate});

  @override
  ConsumerState<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends ConsumerState<_AddTaskSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late DateTime _dueDate;
  String _category = 'general';
  String? _selectedFlockId;
  String? _recurrenceInterval;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descController = TextEditingController();
    _dueDate = widget.initialDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final payload = {
        'title': _titleController.text.trim(),
        'description': _descController.text.trim().isEmpty ? null : _descController.text.trim(),
        'due_date': DateFormat('yyyy-MM-dd').format(_dueDate),
        'status': 'PENDING',
        'category': _category,
        'flock_id': _selectedFlockId,
        if (_recurrenceInterval != null) 'recurrence_interval': _recurrenceInterval,
      };

      await ApiClient.instance.post('/tasks/', data: payload);
      ref.invalidate(tasksProvider);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed submission: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final flocks = ref.watch(broilerProvider).batches;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 24,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Add Schedule Task', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                validator: (v) => v!.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Description (Optional)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedFlockId,
                decoration: const InputDecoration(labelText: 'Associate Flock (Optional)', border: OutlineInputBorder()),
                items: [
                  const DropdownMenuItem(value: null, child: Text('None')),
                  ...flocks.map((f) => DropdownMenuItem(value: f.id, child: Text(f.name))),
                ],
                onChanged: (v) => setState(() => _selectedFlockId = v),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                items: ['general', 'vaccine', 'medication', 'cleaning', 'feeding']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c.toUpperCase())))
                    .toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String?>(
                initialValue: _recurrenceInterval,
                decoration: const InputDecoration(labelText: 'Recurrence (Optional)', border: OutlineInputBorder()),
                items: [
                  const DropdownMenuItem(value: null, child: Text('None (One-time)')),
                  ...['daily', 'weekly', 'monthly'].map((r) => DropdownMenuItem(value: r, child: Text(r.toUpperCase()))),
                ],
                onChanged: (v) => setState(() => _recurrenceInterval = v),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Due Date'),
                subtitle: Text(DateFormat('yyyy-MM-dd').format(_dueDate)),
                trailing: const Icon(LucideIcons.calendar),
                onTap: () async {
                  final picked = await showDatePicker(context: context, initialDate: _dueDate, firstDate: DateTime.now().subtract(const Duration(days: 365)), lastDate: DateTime.now().add(const Duration(days: 365)));
                  if (picked != null) setState(() => _dueDate = picked);
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Create Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

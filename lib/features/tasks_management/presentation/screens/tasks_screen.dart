import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:mobile/shared/providers/data_providers.dart';
import 'package:mobile/core/models/broiler_models.dart';
import 'package:mobile/core/utils/toast_service.dart';
import 'package:mobile/core/utils/error_handler.dart';
import 'package:mobile/shared/widgets/custom_card.dart';
import 'package:mobile/shared/widgets/custom_button.dart';
import 'package:mobile/shared/widgets/custom_input.dart';
import 'package:mobile/app/theme/app_theme.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(taskManagementProvider);
    final profileAsync = ref.watch(profileProvider);
    final user = profileAsync.value;
    final canEdit = user?.canEdit ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Farm Tasks', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(taskManagementProvider),
        child: tasksAsync.when(
          data: (tasks) {
            if (tasks.isEmpty) {
              return _buildEmptyState(context);
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return _buildTaskItem(context, task, canEdit);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text(getFriendlyErrorMessage(e))),
        ),
      ),
      floatingActionButton: canEdit
          ? FloatingActionButton(
              onPressed: () => _showTaskDialog(context),
              child: const Icon(LucideIcons.plus),
            )
          : null,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.checkCircle, size: 64, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text('No tasks found. Create one to get started!', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
        ],
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context, ScheduledTask task, bool canEdit) {
    final theme = Theme.of(context);
    final isCompleted = task.status == 'COMPLETED';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CustomCard(
        child: InkWell(
          onTap: canEdit ? () => _showTaskDialog(context, task: task) : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    isCompleted ? LucideIcons.checkCircle2 : LucideIcons.circle,
                    color: isCompleted ? theme.extension<CustomColors>()?.success ?? Colors.green : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  onPressed: canEdit 
                      ? () {
                          HapticFeedback.mediumImpact();
                          ref.read(taskManagementProvider.notifier).updateTask(
                            task.id,
                            {'status': isCompleted ? 'PENDING' : 'COMPLETED'},
                          );
                        }
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                          color: isCompleted ? theme.colorScheme.onSurface.withValues(alpha: 0.5) : null,
                        ),
                      ),
                      if (task.description != null && task.description!.isNotEmpty)
                        Text(
                          task.description!,
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(LucideIcons.calendar, size: 12, color: theme.colorScheme.primary),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('MMM dd, yyyy').format(task.dueDate),
                            style: TextStyle(fontSize: 11, color: theme.colorScheme.primary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (canEdit)
                  IconButton(
                    icon: Icon(LucideIcons.trash2, size: 18, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                    onPressed: () => _confirmDelete(context, task.id),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTaskDialog(BuildContext context, {ScheduledTask? task}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => _TaskFormSheet(task: task),
    );
  }

  void _confirmDelete(BuildContext context, String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      ref.read(taskManagementProvider.notifier).deleteTask(id);
    }
  }
}

class _TaskFormSheet extends ConsumerStatefulWidget {
  final ScheduledTask? task;
  const _TaskFormSheet({this.task});

  @override
  ConsumerState<_TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends ConsumerState<_TaskFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime _dueDate = DateTime.now();
  String _category = 'general';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descController.text = widget.task!.description ?? '';
      _dueDate = widget.task!.dueDate;
      _category = widget.task!.category;
    }
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

    final data = {
      'title': _titleController.text.trim(),
      'description': _descController.text.trim(),
      'due_date': _dueDate.toIso8601String().split('T')[0],
      'category': _category,
    };

    try {
      if (widget.task != null) {
        await ref.read(taskManagementProvider.notifier).updateTask(widget.task!.id, data);
      } else {
        await ref.read(taskManagementProvider.notifier).createTask(data);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ToastService.showError(context, getFriendlyErrorMessage(e));
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
              widget.task != null ? 'Edit Task' : 'New Task',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomInput(
              label: 'Title',
              hintText: 'e.g., Feed the birds',
              controller: _titleController,
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            CustomInput(
              label: 'Description',
              hintText: 'Any specific instructions?',
              controller: _descController,
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Due Date'),
              subtitle: Text(DateFormat('MMM dd, yyyy').format(_dueDate)),
              trailing: const Icon(LucideIcons.calendar),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _dueDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2030),
                );
                if (picked != null) setState(() => _dueDate = picked);
              },
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: widget.task != null ? 'Update Task' : 'Create Task',
              onPressed: _submit,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}

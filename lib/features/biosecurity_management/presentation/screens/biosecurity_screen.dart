import 'package:mobile/presentation/widgets/custom_divider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

import '../../../../providers/data_providers.dart';

import '../../../../core/network/api_client.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/utils/toast_service.dart';
import '../../../../presentation/widgets/app_drawer.dart';
import '../../../../presentation/widgets/custom_button.dart';
import '../../../../presentation/widgets/custom_card.dart';
import '../../../../presentation/widgets/custom_input.dart';

class BiosecurityScreen extends ConsumerStatefulWidget {
  const BiosecurityScreen({super.key});

  @override
  ConsumerState<BiosecurityScreen> createState() => _BiosecurityScreenState();
}

class _BiosecurityScreenState extends ConsumerState<BiosecurityScreen> {
  final List<String> _checklistItems = [
    'Footbath solution changed',
    'Visitor log checked',
    'Protective gear worn',
    'Dead birds removed properly',
    'House surroundings clean'
  ];

  final List<bool> _checkedStatus = List.filled(5, false);
  final _completedByController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitChecklist() async {
    if (_completedByController.text.trim().isEmpty) {
      ToastService.showError(context, 'Please enter your name');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final items = List.generate(_checklistItems.length, (index) => {
        'task': _checklistItems[index],
        'completed': _checkedStatus[index],
        'notes': '',
      });
      
      await ApiClient.instance.post(ApiEndpoints.biosecurity, data: {
        'items': items,
        'completed_by': _completedByController.text.trim(),
        'notes': _notesController.text.trim(),
        'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      });

      if (mounted) {
        ToastService.showSuccess(context, 'Biosecurity checklist submitted');
        ref.invalidate(biosecurityProvider);
        setState(() {
          _checkedStatus.fillRange(0, _checkedStatus.length, false);
          _completedByController.clear();
          _notesController.clear();
        });
      }
    } catch (e) {
      if (mounted) ToastService.showError(context, 'Failed to submit: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _completedByController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final biosecurityAsync = ref.watch(biosecurityProvider);
    final records = biosecurityAsync.value ?? [];
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final hasToday = records.any((r) => r['date']?.toString().startsWith(today) == true);
    final todayStatus = hasToday ? 'Completed' : 'Pending';

    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final recentRecords = records.where((r) => DateTime.tryParse(r['date']?.toString() ?? '')?.isAfter(thirtyDaysAgo) == true).toList();
    final compliance = records.isEmpty ? '0.0%' : '${(recentRecords.length / 30.0 * 100).clamp(0.0, 100.0).toStringAsFixed(1)}%';

    final startOfWeek = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
    final weekRecords = records.where((r) => DateTime.tryParse(r['date']?.toString() ?? '')?.isAfter(startOfWeek) == true).toList();
    final weekStat = '${weekRecords.length}/7';

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Biosecurity Checklists', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Daily farm hygiene and safety checks'),
            const SizedBox(height: 16),
            
            // Stats Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard(context, 'Today\'s Status', todayStatus, LucideIcons.calendar, hasToday ? theme.colorScheme.primary : theme.colorScheme.secondary),
                _buildStatCard(context, '30-Day Compliance', compliance, LucideIcons.shield, theme.colorScheme.primary),
                _buildStatCard(context, 'Checklist Items', '${_checklistItems.length}', LucideIcons.clipboardCheck, theme.colorScheme.onSurface),
                _buildStatCard(context, 'This Week', weekStat, LucideIcons.checkCircle, theme.colorScheme.onSurface),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Today's Checklist
            CustomCard(
              isPremium: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                   Row(
                    children: [
                      Icon(LucideIcons.clipboardCheck, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text('Today\'s Checklist', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  ...List.generate(_checklistItems.length, (index) {
                    return CheckboxListTile(
                      title: Text(
                        _checklistItems[index],
                        style: TextStyle(
                          decoration: _checkedStatus[index] ? TextDecoration.lineThrough : null,
                          color: _checkedStatus[index] ? theme.colorScheme.onSurface.withValues(alpha: 0.5) : null,
                        ),
                      ),
                      value: _checkedStatus[index],
                      onChanged: (val) {
                        setState(() {
                          _checkedStatus[index] = val ?? false;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    );
                  }),
                  
                  const CustomDivider(),
                  const SizedBox(height: 16),
                  CustomInput(
                    label: 'Completed By *',
                    hintText: 'Your name',
                    controller: _completedByController,
                  ),
                  const SizedBox(height: 16),
                  CustomInput(
                    label: 'Additional Notes',
                    hintText: 'Any issues or observations...',
                    controller: _notesController,
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Submit Checklist',
                    icon: const Icon(LucideIcons.checkCircle, size: 18),
                    isLoading: _isSubmitting,
                    onPressed: _submitChecklist,
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Recent History
            Text('Recent History', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            biosecurityAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Error loading history: $err'),
              data: (records) {
                if (records.isEmpty) {
                  return CustomCard(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          Icon(LucideIcons.clipboardCheck, size: 48, color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
                          const SizedBox(height: 8),
                          const Text('No checklists recorded yet'),
                          Text('Complete today\'s checklist to start tracking', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                        ],
                      ),
                    ),
                  );
                }
                
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final item = records.reversed.toList()[index];
                    final dateStr = item['date']?.toString() ?? '';
                    final date = DateTime.tryParse(dateStr) ?? DateTime.now();
                    
                    final items = item['items'] as List? ?? [];
                    final completedCount = items.where((i) => i['completed'] == true).length;
                    
                    return CustomCard(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                          child: Icon(LucideIcons.clipboardCheck, color: theme.colorScheme.primary, size: 20),
                        ),
                        title: Text('Compliance: $completedCount/${items.length} Checked'),
                        subtitle: Text('${DateFormat('MMM dd, yyyy').format(date)} - By ${item['completed_by'] ?? 'Unknown'}'),
                        trailing: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          itemBuilder: (ctx2) => const [
                            PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red)))
                          ],
                          onSelected: (val) async {
                            if (val == 'delete') {
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

                                  await ApiClient.instance.delete('${ApiEndpoints.biosecurity}${item['id']}');

                                  ref.invalidate(biosecurityProvider);

                                } catch (e) {

                                  if (context.mounted) {

                                    String message = 'Failed to delete';

                                    if (e is DioException && e.response?.statusCode == 404) {

                                      message = 'Record already deleted';

                                      ref.invalidate(biosecurityProvider);

                                    }

                                    ToastService.showError(context, message);

                                  }

                                }
                              }
                            }
                          },
                        ),
                        onTap: () => _showCheckDetails(context, item),
                      ),
                    );
                  },
                );
              },
            ),
            
             // Reminder Warning
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                border: Border.all(color: Colors.orange),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.alertTriangle, color: Colors.orange),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Reminder: Complete today\'s biosecurity checklist to maintain farm hygiene standards.',
                      style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 13),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showCheckDetails(BuildContext context, Map<String, dynamic> item) {
    final items = item['items'] as List? ?? [];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Biosecurity Checklist Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Date: ${item['date'] ?? 'N/A'}', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('By: ${item['completed_by'] ?? 'N/A'}', style: const TextStyle(fontWeight: FontWeight.bold)),
              if (item['notes']?.toString().isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Text('Notes: ${item['notes']}'),
              ],
              const CustomDivider(),
              const Text('Tasks Breakdown:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...items.map((i) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Icon(
                          i['completed'] == true ? Icons.check_circle : Icons.circle_outlined,
                          color: i['completed'] == true ? Colors.green : Colors.grey,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(i['task'] ?? '')),
                      ],
                    ),
                  )),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color valueColor) {
    return CustomCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), maxLines: 1)),
              Icon(icon, size: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
            ],
          ),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: valueColor),
          ),
        ],
      ),
    );
  }
}

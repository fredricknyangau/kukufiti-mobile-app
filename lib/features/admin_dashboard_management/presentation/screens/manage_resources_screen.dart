import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../presentation/widgets/custom_card.dart';
import '../../../../providers/data_providers.dart';

class ManageResourcesScreen extends ConsumerWidget {
  const ManageResourcesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resourcesAsync = ref.watch(resourcesProvider);
    final profileAsync = ref.watch(profileProvider);
    final canEdit = profileAsync.value?.isAdmin ?? false;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Resources', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: canEdit ? FloatingActionButton(
        onPressed: () => _showResourceFormDialog(context: context, ref: ref),
        child: const Icon(LucideIcons.plus),
      ) : null,
      body: resourcesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error loading resources: ${e.toString().split('\n').first}')),
        data: (guides) {
          if (guides.isEmpty) {
            return const Center(child: Text('No resources available.'));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(resourcesProvider),
            child: ListView(
              padding: const EdgeInsets.all(16),
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
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: guides.length,
                  itemBuilder: (context, index) {
                    final guide = guides[index];
                    IconData iconData = LucideIcons.bookOpen;
                    if (guide['icon'] == 'syringe') iconData = LucideIcons.syringe;
                    if (guide['icon'] == 'alertTriangle') iconData = LucideIcons.alertTriangle;
                    if (guide['icon'] == 'wheat') iconData = LucideIcons.wheat;

                    return _buildResourceCard(
                      context,
                      ref,
                      guide,
                      iconData,
                      canEdit,
                    );
                  },
                ),
              ],
            ),
          );

        },
      ),
    );
  }

  Widget _buildResourceCard(BuildContext context, WidgetRef ref, Map<String, dynamic> guide, IconData icon, bool canEdit) {
    final theme = Theme.of(context);
    final title = guide['title']?.toString() ?? 'Guide';
    final subtitle = guide['description']?.toString() ?? '';
    final content = guide['content']?.toString() ?? '';
    final id = guide['id']?.toString() ?? '';

    return CustomCard(
      isPremium: true,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: theme.colorScheme.primary, size: 24),
              ),
               if (canEdit)
                 Row(
                   mainAxisSize: MainAxisSize.min,
                   children: [
                     IconButton(
                       icon: const Icon(LucideIcons.pencil, size: 16),
                       padding: EdgeInsets.zero,
                       constraints: const BoxConstraints(),
                       onPressed: () => _showResourceFormDialog(context: context, ref: ref, guide: guide),
                     ),
                     const SizedBox(width: 4),
                     IconButton(
                       icon: Icon(LucideIcons.trash2, size: 16, color: theme.colorScheme.error),
                       padding: EdgeInsets.zero,
                       constraints: const BoxConstraints(),
                       onPressed: () => _deleteResource(context, ref, id),
                     ),
                   ],
                 ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              subtitle,
              style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 11),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () => _showGuideViewer(context, title, content),
              icon: const Icon(LucideIcons.bookOpen, size: 14),
              label: const Text('Read Guide', style: TextStyle(fontSize: 12)),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
              ),
            ),
          )
        ],
      ),
    );
  }

  void _showGuideViewer(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Text(content, style: const TextStyle(height: 1.5)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showResourceFormDialog({required BuildContext context, required WidgetRef ref, Map<String, dynamic>? guide}) {
    final isEditing = guide != null;
    final titleController = TextEditingController(text: guide?['title']);
    final descController = TextEditingController(text: guide?['description']);
    final contentController = TextEditingController(text: guide?['content']);
    String category = guide?['category'] ?? 'General';
    String icon = guide?['icon'] ?? 'bookOpen';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Resource' : 'Add Resource', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(labelText: 'Content'),
                  maxLines: 4,
                ),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: const [
                    DropdownMenuItem(value: 'General', child: Text('General')),
                    DropdownMenuItem(value: 'Health', child: Text('Health')),
                    DropdownMenuItem(value: 'Nutrition', child: Text('Nutrition')),
                    DropdownMenuItem(value: 'Management', child: Text('Management')),
                  ],
                  onChanged: (val) => category = val ?? 'General',
                ),
                DropdownButtonFormField<String>(
                  initialValue: icon,
                  decoration: const InputDecoration(labelText: 'Icon'),
                  items: const [
                    DropdownMenuItem(value: 'bookOpen', child: Text('Book')),
                    DropdownMenuItem(value: 'syringe', child: Text('Syringe')),
                    DropdownMenuItem(value: 'alertTriangle', child: Text('Warning')),
                    DropdownMenuItem(value: 'wheat', child: Text('Wheat')),
                  ],
                  onChanged: (val) => icon = val ?? 'bookOpen',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final payload = {
                  'title': titleController.text,
                  'description': descController.text,
                  'content': contentController.text,
                  'category': category,
                  'icon': icon,
                };
                
                try {
                  if (guide != null) {
                    await ApiClient.instance.put('${ApiEndpoints.resources}${guide['id']}', data: payload);
                  } else {
                    await ApiClient.instance.post(ApiEndpoints.resources, data: payload);
                  }
                  ref.invalidate(resourcesProvider);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }

              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteResource(BuildContext context, WidgetRef ref, String id) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Resource'),
        content: const Text('Are you sure you want to delete this resource?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              try {
                await ApiClient.instance.delete('${ApiEndpoints.resources}$id');
                ref.invalidate(resourcesProvider);
                if (!context.mounted) return;
                Navigator.pop(context);
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ErrorDeleting: $e')));
              }

            },
            child: Text('Delete', style: TextStyle(color: theme.colorScheme.error)),
          ),
        ],
      ),
    );
  }
}

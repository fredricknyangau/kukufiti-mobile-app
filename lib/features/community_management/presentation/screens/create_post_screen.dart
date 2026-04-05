import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mobile/features/community_management/providers/community_provider.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _imageUrlController = TextEditingController();
  String? _selectedCategoryId;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    await ref.read(communityActionProvider.notifier).createPost(
      title: _titleController.text,
      content: _contentController.text,
      categoryId: _selectedCategoryId,
      imageUrl: _imageUrlController.text.isNotEmpty ? _imageUrlController.text : null,
    );

    if (mounted) {
      if (ref.read(communityActionProvider).hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${ref.read(communityActionProvider).error}')),
        );
      } else {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(communityCategoriesProvider);
    final isSubmitting = ref.watch(communityActionProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        actions: [
          if (isSubmitting)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            TextButton(
              onPressed: _submit,
              child: const Text('POST', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Category Dropdown
            categoriesAsync.when(
              data: (categories) => DropdownButtonFormField<String>(
                initialValue: _selectedCategoryId,
                decoration: const InputDecoration(
                  labelText: 'Discussion Topic',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(LucideIcons.tag),
                ),
                items: categories.map((c) => DropdownMenuItem(
                  value: c.id,
                  child: Text(c.name),
                )).toList(),
                onChanged: (val) => setState(() => _selectedCategoryId = val),
                validator: (val) => val == null ? 'Please select a topic' : null,
              ),
              loading: () => const LinearProgressIndicator(),
              error: (err, stack) => const Text('Error loading categories'),
            ),
            const SizedBox(height: 24),
            
            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'What is on your mind?',
                border: OutlineInputBorder(),
              ),
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              validator: (val) => val == null || val.isEmpty ? 'Title is required' : null,
            ),
            const SizedBox(height: 24),
            
            // Content
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Content',
                hintText: 'Share your experience or ask a question...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 8,
              validator: (val) => val == null || val.isEmpty ? 'Content is required' : null,
            ),
            const SizedBox(height: 24),
            
            // Image URL (Mocking for now as requested)
            TextFormField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                labelText: 'Image URL (optional)',
                hintText: 'http://example.com/image.jpg',
                border: OutlineInputBorder(),
                prefixIcon: Icon(LucideIcons.image),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Initial version supports external image links. In-app upload coming soon.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

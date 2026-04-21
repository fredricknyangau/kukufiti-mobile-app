import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mobile/features/community_management/data/models/community_models.dart';
import 'package:mobile/features/community_management/providers/community_provider.dart';
import 'package:mobile/shared/widgets/custom_card.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:go_router/go_router.dart';

class CommunityFeedScreen extends ConsumerStatefulWidget {
  const CommunityFeedScreen({super.key});

  @override
  ConsumerState<CommunityFeedScreen> createState() => _CommunityFeedScreenState();
}

class _CommunityFeedScreenState extends ConsumerState<CommunityFeedScreen> {
  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(communityCategoriesProvider);
    final feedAsync = ref.watch(communityFeedProvider(_selectedCategoryId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmer Community'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.search),
            onPressed: () {
              // Toggle search visibility
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCategoryFilter(categoriesAsync),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(communityFeedProvider(_selectedCategoryId));
              },
              child: feedAsync.when(
                data: (posts) => posts.isEmpty
                    ? _buildEmptyState(theme)
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: posts.length,
                        itemBuilder: (context, index) => _buildPostCard(context, posts[index]),
                      ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(child: Text('Error: $e')),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/community/create'),
        icon: const Icon(LucideIcons.plus),
        label: const Text('New Post'),
      ),
    );
  }

  Widget _buildCategoryFilter(AsyncValue<List<CommunityCategory>> categoriesAsync) {
    return categoriesAsync.when(
      data: (categories) => Container(
        height: 60,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: categories.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: const Text('All'),
                  selected: _selectedCategoryId == null,
                  onSelected: (val) => setState(() => _selectedCategoryId = null),
                ),
              );
            }
            final cat = categories[index - 1];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(cat.name),
                selected: _selectedCategoryId == cat.id,
                onSelected: (val) => setState(() => _selectedCategoryId = val ? cat.id : null),
                selectedColor: Color(int.parse(cat.color.replaceFirst('#', '0xFF'))).withValues(alpha: 0.2),
                labelStyle: TextStyle(
                  color: _selectedCategoryId == cat.id ? Color(int.parse(cat.color.replaceFirst('#', '0xFF'))) : null,
                  fontWeight: _selectedCategoryId == cat.id ? FontWeight.bold : null,
                ),
              ),
            );
          },
        ),
      ),
      loading: () => const SizedBox(height: 60),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildPostCard(BuildContext context, CommunityPost post) {
    final theme = Theme.of(context);

    return CustomCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.zero,
      onTap: () => context.push('/community/post', extra: post.id),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                  child: Text(post.author.fullName?[0].toUpperCase() ?? 'F'),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.author.fullName ?? 'Farmer', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        if (post.category != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Color(int.parse(post.category!.color.replaceFirst('#', '0xFF'))).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              post.category!.name.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(int.parse(post.category!.color.replaceFirst('#', '0xFF'))),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          timeago.format(post.createdAt),
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                if (post.isPinned)
                  const Icon(LucideIcons.pin, size: 16, color: Colors.orange),
              ],
            ),
          ),
          
          // Post Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  post.content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          
          // Post Image (if any)
          if (post.imageUrl != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: ClipRRect(
                child: Image.network(
                  post.imageUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 100,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Icon(LucideIcons.image, color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              ),
            ),
            
          // Engagement Bar
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                _buildActionButton(
                  icon: post.likedByMe ? LucideIcons.heart : LucideIcons.heart,
                  label: '${post.likesCount}',
                  color: post.likedByMe ? Colors.red : null,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ref.read(communityActionProvider.notifier).toggleLike(post.id);
                  },
                ),
                _buildActionButton(
                  icon: LucideIcons.messageSquare,
                  label: '${post.commentsCount}',
                  onTap: () => context.push('/community/post', extra: post.id),
                ),
                const Spacer(),
                _buildActionButton(icon: LucideIcons.share2, label: 'Share', onTap: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, Color? color, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.users, size: 80, color: theme.colorScheme.primary.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          const Text('No posts yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text('Be the first to share something with the community!', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

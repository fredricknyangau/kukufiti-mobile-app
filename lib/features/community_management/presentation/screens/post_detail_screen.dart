import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:mobile/features/community_management/data/models/community_models.dart';
import 'package:mobile/features/community_management/providers/community_provider.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  final String postId;
  const PostDetailScreen({super.key, required this.postId});

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();

  Future<void> _submitComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;
    
    await ref.read(communityActionProvider.notifier).addComment(widget.postId, content);
    if (!mounted) return;
    _commentController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final postAsync = ref.watch(postDetailProvider(widget.postId));
    final commentsAsync = ref.watch(postCommentsProvider(widget.postId));

    return Scaffold(
      appBar: AppBar(title: const Text('Discussion')),
      body: postAsync.when(
        data: (post) => Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                   _buildPostContent(theme, post),
                   const Padding(
                     padding: EdgeInsets.symmetric(vertical: 24),
                     child: Text('Comments', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                   ),
                   _buildCommentsList(commentsAsync),
                ],
              ),
            ),
            _buildCommentInput(theme),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildPostContent(ThemeData theme, CommunityPost post) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
                Text(timeago.format(post.createdAt), style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(post.title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text(post.content, style: theme.textTheme.bodyLarge?.copyWith(height: 1.5)),
        if (post.imageUrl != null)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(post.imageUrl!, fit: BoxFit.cover),
            ),
          ),
        const SizedBox(height: 24),
        Row(
          children: [
            _buildStat(LucideIcons.heart, '${post.likesCount}', post.likedByMe ? Colors.red : null),
            const SizedBox(width: 24),
            _buildStat(LucideIcons.messageSquare, '${post.commentsCount}', null),
            const Spacer(),
            IconButton(icon: const Icon(LucideIcons.share2), onPressed: () {}),
          ],
        ),
        const Divider(height: 32),
      ],
    );
  }

  Widget _buildStat(IconData icon, String label, Color? color) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildCommentsList(AsyncValue<List<PostComment>> commentsAsync) {
    return commentsAsync.when(
      data: (comments) => ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: comments.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) => _buildCommentTile(comments[index]),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Text('Error loading comments: $e'),
    );
  }

  Widget _buildCommentTile(PostComment comment) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
          child: Text(comment.author.fullName?[0].toUpperCase() ?? 'F', style: const TextStyle(fontSize: 12)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(comment.author.fullName ?? 'Farmer', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(width: 8),
                  Text(timeago.format(comment.createdAt), style: theme.textTheme.bodySmall?.copyWith(fontSize: 10, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 4),
              Text(comment.content, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommentInput(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.black12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Share your thoughts...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              maxLines: null,
            ),
          ),
          const SizedBox(width: 12),
          IconButton.filled(
            onPressed: _submitComment,
            icon: const Icon(LucideIcons.send, size: 18),
          ),
        ],
      ),
    );
  }
}

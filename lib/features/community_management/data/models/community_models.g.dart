// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommunityCategory _$CommunityCategoryFromJson(Map<String, dynamic> json) =>
    CommunityCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      color: json['color'] as String,
      icon: json['icon'] as String?,
    );

Map<String, dynamic> _$CommunityCategoryToJson(CommunityCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
      'description': instance.description,
      'color': instance.color,
      'icon': instance.icon,
    };

AuthorMini _$AuthorMiniFromJson(Map<String, dynamic> json) => AuthorMini(
  id: json['id'] as String,
  fullName: json['full_name'] as String?,
  role: json['role'] as String,
);

Map<String, dynamic> _$AuthorMiniToJson(AuthorMini instance) =>
    <String, dynamic>{
      'id': instance.id,
      'full_name': instance.fullName,
      'role': instance.role,
    };

CommunityPost _$CommunityPostFromJson(
  Map<String, dynamic> json,
) => CommunityPost(
  id: json['id'] as String,
  title: json['title'] as String,
  content: json['content'] as String,
  imageUrl: json['image_url'] as String?,
  images: (json['images'] as List<dynamic>).map((e) => e as String).toList(),
  authorId: json['author_id'] as String,
  author: AuthorMini.fromJson(json['author'] as Map<String, dynamic>),
  category: json['category'] == null
      ? null
      : CommunityCategory.fromJson(json['category'] as Map<String, dynamic>),
  likesCount: (json['likes_count'] as num).toInt(),
  commentsCount: (json['comments_count'] as num).toInt(),
  isPinned: json['is_pinned'] as bool,
  isClosed: json['is_closed'] as bool,
  createdAt: DateTime.parse(json['created_at'] as String),
  likedByMe: json['liked_by_me'] as bool,
);

Map<String, dynamic> _$CommunityPostToJson(CommunityPost instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'image_url': instance.imageUrl,
      'images': instance.images,
      'author_id': instance.authorId,
      'author': instance.author,
      'category': instance.category,
      'likes_count': instance.likesCount,
      'comments_count': instance.commentsCount,
      'is_pinned': instance.isPinned,
      'is_closed': instance.isClosed,
      'created_at': instance.createdAt.toIso8601String(),
      'liked_by_me': instance.likedByMe,
    };

PostComment _$PostCommentFromJson(Map<String, dynamic> json) => PostComment(
  id: json['id'] as String,
  postId: json['post_id'] as String,
  authorId: json['author_id'] as String,
  author: AuthorMini.fromJson(json['author'] as Map<String, dynamic>),
  content: json['content'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$PostCommentToJson(PostComment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'post_id': instance.postId,
      'author_id': instance.authorId,
      'author': instance.author,
      'content': instance.content,
      'created_at': instance.createdAt.toIso8601String(),
    };

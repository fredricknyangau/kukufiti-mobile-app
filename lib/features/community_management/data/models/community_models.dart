import 'package:json_annotation/json_annotation.dart';

part 'community_models.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class CommunityCategory {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String color;
  final String? icon;

  CommunityCategory({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    required this.color,
    this.icon,
  });

  factory CommunityCategory.fromJson(Map<String, dynamic> json) => _$CommunityCategoryFromJson(json);
  Map<String, dynamic> toJson() => _$CommunityCategoryToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class AuthorMini {
  final String id;
  final String? fullName;
  final String role;

  AuthorMini({
    required this.id,
    this.fullName,
    required this.role,
  });

  factory AuthorMini.fromJson(Map<String, dynamic> json) => _$AuthorMiniFromJson(json);
  Map<String, dynamic> toJson() => _$AuthorMiniToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class CommunityPost {
  final String id;
  final String title;
  final String content;
  final String? imageUrl;
  final List<String> images;
  final String authorId;
  final AuthorMini author;
  final CommunityCategory? category;
  final int likesCount;
  final int commentsCount;
  final bool isPinned;
  final bool isClosed;
  final DateTime createdAt;
  final bool likedByMe;

  CommunityPost({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
    required this.images,
    required this.authorId,
    required this.author,
    this.category,
    required this.likesCount,
    required this.commentsCount,
    required this.isPinned,
    required this.isClosed,
    required this.createdAt,
    required this.likedByMe,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) => _$CommunityPostFromJson(json);
  Map<String, dynamic> toJson() => _$CommunityPostToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class PostComment {
  final String id;
  final String postId;
  final String authorId;
  final AuthorMini author;
  final String content;
  final DateTime createdAt;

  PostComment({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.author,
    required this.content,
    required this.createdAt,
  });

  factory PostComment.fromJson(Map<String, dynamic> json) => _$PostCommentFromJson(json);
  Map<String, dynamic> toJson() => _$PostCommentToJson(this);
}

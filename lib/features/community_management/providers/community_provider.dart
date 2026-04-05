import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/api_endpoints.dart';
import 'package:mobile/core/storage/hive_cache_service.dart';
import 'package:mobile/features/community_management/data/models/community_models.dart';
import 'package:mobile/providers/auth_provider.dart';

// Reuse the data extraction logic from the main data_providers
dynamic _extractData(dynamic responseData) {
  if (responseData is Map<String, dynamic>) {
    if (responseData.containsKey('data')) return responseData['data'];
    if (responseData.containsKey('items')) return responseData['items'];
  }
  return responseData;
}

void _setupKeepAlive(Ref ref) {
  final link = ref.keepAlive();
  ref.listen<AuthState>(authProvider, (prev, next) {
    if (!next.isAuthenticated) link.close();
  });

  Timer? timer;
  ref.onDispose(() => timer?.cancel());
  ref.onCancel(() => timer = Timer(const Duration(minutes: 5), () => link.close()));
  ref.onResume(() => timer?.cancel());
}

// --- PROVIDERS ---

final communityCategoriesProvider = FutureProvider.autoDispose<List<CommunityCategory>>((ref) async {
  _setupKeepAlive(ref);
  const endpoint = ApiEndpoints.communityCategories;
  try {
    final res = await ApiClient.instance.get(endpoint);
    final data = List<dynamic>.from(_extractData(res.data) ?? []);
    await HiveCacheService.cacheData(endpoint, data);
    return data.map((e) => CommunityCategory.fromJson(Map<String, dynamic>.from(e))).toList();
  } catch (e) {
    final cached = HiveCacheService.getCachedData(endpoint);
    if (cached != null) {
      return List<dynamic>.from(cached).map((e) => CommunityCategory.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    rethrow;
  }
});

final communityFeedProvider = FutureProvider.autoDispose.family<List<CommunityPost>, String?>((ref, categoryId) async {
  _setupKeepAlive(ref);
  final queryParams = categoryId != null ? '?category_id=$categoryId' : '';
  final endpoint = '${ApiEndpoints.communityFeed}$queryParams';
  
  try {
    final res = await ApiClient.instance.get(endpoint);
    final data = List<dynamic>.from(_extractData(res.data) ?? []);
    await HiveCacheService.cacheData(endpoint, data);
    return data.map((e) => CommunityPost.fromJson(Map<String, dynamic>.from(e))).toList();
  } catch (e) {
    final cached = HiveCacheService.getCachedData(endpoint);
    if (cached != null) {
      return List<dynamic>.from(cached).map((e) => CommunityPost.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    rethrow;
  }
});

final postDetailProvider = FutureProvider.autoDispose.family<CommunityPost, String>((ref, postId) async {
  _setupKeepAlive(ref);
  final endpoint = ApiEndpoints.communityPostDetails(postId);
  final res = await ApiClient.instance.get(endpoint);
  return CommunityPost.fromJson(Map<String, dynamic>.from(_extractData(res.data)));
});

final postCommentsProvider = FutureProvider.autoDispose.family<List<PostComment>, String>((ref, postId) async {
  _setupKeepAlive(ref);
  final endpoint = ApiEndpoints.communityPostComments(postId);
  final res = await ApiClient.instance.get(endpoint);
  final data = List<dynamic>.from(_extractData(res.data) ?? []);
  return data.map((e) => PostComment.fromJson(Map<String, dynamic>.from(e))).toList();
});

// --- ACTIONS ---

class CommunityActionNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> createPost({
    required String title,
    required String content,
    String? categoryId,
    String? imageUrl,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ApiClient.instance.post(ApiEndpoints.communityFeed.replaceAll('/feed', '/posts'), data: {
        'title': title,
        'content': content,
        'category_id': categoryId,
        'image_url': imageUrl,
      });
      ref.invalidate(communityFeedProvider);
    });
  }

  Future<void> toggleLike(String postId) async {
    await AsyncValue.guard(() async {
      await ApiClient.instance.post(ApiEndpoints.communityPostLike(postId));
      // Invalidate both feed and detail to reflect new like count locally
      ref.invalidate(communityFeedProvider);
      ref.invalidate(postDetailProvider(postId));
    });
  }

  Future<void> addComment(String postId, String content) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ApiClient.instance.post(ApiEndpoints.communityPostComments(postId), data: {
        'content': content,
      });
      ref.invalidate(postCommentsProvider(postId));
      ref.invalidate(postDetailProvider(postId));
    });
  }
}

final communityActionProvider = AsyncNotifierProvider<CommunityActionNotifier, void>(() {
  return CommunityActionNotifier();
});

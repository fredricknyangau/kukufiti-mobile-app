// user_providers.dart — Riverpod providers for user profile and farm membership
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../core/storage/hive_cache_service.dart';
import '../core/models/broiler_models.dart';
import 'billing_providers.dart';
import '_provider_utils.dart';

final profileProvider = FutureProvider.autoDispose<User>((ref) async {
  setupKeepAlive(ref);
  const cacheKey = 'profile_data';
  try {
    final res = await ApiClient.instance.get(ApiEndpoints.profile);
    final data = Map<String, dynamic>.from(extractData(res.data) ?? {});
    await HiveCacheService.cacheData(cacheKey, data);
    return User.fromJson(data);
  } catch (e) {
    final cached = HiveCacheService.getCachedData(cacheKey);
    if (cached != null) return User.fromJson(Map<String, dynamic>.from(cached));
    rethrow;
  }
});

final farmsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  setupKeepAlive(ref);
  final planDetails = ref.watch(planDetailsProvider).value;
  final features = List<String>.from(planDetails?['features'] ?? []);

  final profile = ref.watch(profileProvider).value;
  if (profile?.isAdmin != true && !features.contains('multi_farm')) {
    return [];
  }
  final res = await ApiClient.instance.get(ApiEndpoints.farms);
  return List<dynamic>.from(extractData(res.data) ?? []);
});

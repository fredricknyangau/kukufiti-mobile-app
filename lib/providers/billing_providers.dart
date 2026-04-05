// billing_providers.dart — Riverpod providers for subscriptions and plan details
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../core/storage/hive_cache_service.dart';
import '_provider_utils.dart';

final subscriptionProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  setupKeepAlive(ref);
  const cacheKey = 'subscription';
  try {
    final res = await ApiClient.instance.get(ApiEndpoints.mySubscription);
    final data = Map<String, dynamic>.from(extractData(res.data) ?? {});
    await HiveCacheService.cacheData(cacheKey, data);
    return data;
  } catch (e) {
    final cached = HiveCacheService.getCachedData(cacheKey);
    if (cached != null) return Map<String, dynamic>.from(cached);
    rethrow;
  }
});

final planDetailsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  setupKeepAlive(ref);
  const cacheKey = 'plan_details';
  try {
    final res = await ApiClient.instance.get(ApiEndpoints.planDetails);
    final data = Map<String, dynamic>.from(extractData(res.data) ?? {});
    await HiveCacheService.cacheData(cacheKey, data);
    return data;
  } catch (e) {
    final cached = HiveCacheService.getCachedData(cacheKey);
    if (cached != null) return Map<String, dynamic>.from(cached);
    rethrow;
  }
});

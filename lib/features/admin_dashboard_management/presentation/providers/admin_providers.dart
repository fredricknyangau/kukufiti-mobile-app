// admin_providers.dart — admin stats, transactions, users for admin screens
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/api_endpoints.dart';
import 'package:mobile/core/storage/hive_cache_service.dart';
import 'package:mobile/shared/utils/_provider_utils.dart';

final adminStatsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  setupKeepAlive(ref);
  const cacheKey = 'admin_stats';
  try {
    final res = await ApiClient.instance.get(ApiEndpoints.adminStats);
    final data = Map<String, dynamic>.from(extractData(res.data) ?? {});
    await HiveCacheService.cacheData(cacheKey, data);
    return data;
  } catch (e) {
    final cached = HiveCacheService.getCachedData(cacheKey);
    if (cached != null) return Map<String, dynamic>.from(cached);
    rethrow;
  }
});

final adminTransactionsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  setupKeepAlive(ref);
  return fetchListWithFallback(endpoint: ApiEndpoints.adminTransactions);
});

final adminUsersProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  setupKeepAlive(ref);
  final res = await ApiClient.instance.get('/admin/users');
  return List<dynamic>.from(extractData(res.data) ?? []);
});

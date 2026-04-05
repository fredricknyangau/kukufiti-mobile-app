// analytics_providers.dart — Riverpod providers for dashboard metrics, charts, benchmarks
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../core/storage/hive_cache_service.dart';
import 'billing_providers.dart';
import 'user_providers.dart';
import '_provider_utils.dart';

final dashboardMetricsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  setupKeepAlive(ref);
  const cacheKey = 'dashboard_metrics';
  try {
    final res = await ApiClient.instance.get(ApiEndpoints.dashboardMetrics);
    final data = Map<String, dynamic>.from(extractData(res.data) ?? {});
    await HiveCacheService.cacheData(cacheKey, data);
    return data;
  } catch (e) {
    final cached = HiveCacheService.getCachedData(cacheKey);
    if (cached != null) return Map<String, dynamic>.from(cached);
    rethrow;
  }
});

final financialChartProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  setupKeepAlive(ref);
  final planDetails = ref.watch(planDetailsProvider).value;
  final features = List<String>.from(planDetails?['features'] ?? []);

  final profile = ref.watch(profileProvider).value;
  if (profile?.isAdmin != true && !features.contains('financials')) {
    throw Exception('Financial Analytics require a Professional Plan');
  }

  return fetchListWithFallback(endpoint: ApiEndpoints.financialChart);
});

final benchmarkingProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  setupKeepAlive(ref);
  const cacheKey = 'benchmarking_metrics';
  try {
    final res = await ApiClient.instance.get(ApiEndpoints.benchmarking);
    final data = Map<String, dynamic>.from(extractData(res.data) ?? {});
    await HiveCacheService.cacheData(cacheKey, data);
    return data;
  } catch (e) {
    final cached = HiveCacheService.getCachedData(cacheKey);
    if (cached != null) return Map<String, dynamic>.from(cached);
    rethrow;
  }
});

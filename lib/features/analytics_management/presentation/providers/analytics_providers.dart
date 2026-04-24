// analytics_providers.dart — Riverpod providers for dashboard metrics, charts, benchmarks
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/api_endpoints.dart';
import 'package:mobile/core/storage/hive_cache_service.dart';
import 'package:mobile/shared/providers/data_providers.dart';
import 'package:mobile/shared/utils/_provider_utils.dart';

class DashboardMetricsNotifier extends Notifier<AsyncValue<Map<String, dynamic>>> {
  static const _cacheKey = 'dashboard_metrics';

  @override
  AsyncValue<Map<String, dynamic>> build() {
    // 1. Try to load from cache IMMEDIATELY
    final cached = HiveCacheService.getCachedData(_cacheKey);
    
    // 2. Refresh in background
    Future.microtask(() => refresh());

    if (cached != null) {
      return AsyncValue.data(Map<String, dynamic>.from(cached));
    }
    return const AsyncValue.loading();
  }

  Future<void> refresh() async {
    try {
      final res = await ApiClient.instance.get(ApiEndpoints.dashboardMetrics);
      final data = Map<String, dynamic>.from(extractData(res.data) ?? {});
      await HiveCacheService.cacheData(_cacheKey, data);
      state = AsyncValue.data(data);
    } catch (e, stack) {
      if (state.hasValue) {
        // Keep showing cached data if refresh fails
        debugPrint('DashboardMetrics: Refresh failed, keeping cache: $e');
      } else {
        state = AsyncValue.error(e, stack);
      }
    }
  }
}

final dashboardMetricsProvider = NotifierProvider<DashboardMetricsNotifier, AsyncValue<Map<String, dynamic>>>(
  DashboardMetricsNotifier.new,
);

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

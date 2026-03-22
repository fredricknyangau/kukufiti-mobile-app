import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../core/storage/hive_cache_service.dart';
import 'auth_provider.dart';

// Helper to handle both `{ "data": [...] }`, `{ "items": [...] }` and `[...]` response structures safely.
dynamic _extractData(dynamic responseData) {
  if (responseData is Map<String, dynamic>) {
    if (responseData.containsKey('data')) {
      return responseData['data'];
    }
    if (responseData.containsKey('items')) {
      return responseData['items'];
    }
  }
  return responseData;
}

// Add a helper to keep providers alive for a short duration to make the app feel faster
void _setupKeepAlive(Ref ref) {
  final link = ref.keepAlive();
  
  // Invalidate cache immediately on logout to prevent state leak across accounts
  ref.listen<AuthState>(
    authProvider,
    (prev, next) {
      if (!next.isAuthenticated) {
        link.close();
      }
    },
  );

  // Keep the data in memory for 5 minutes after the last screen using it is closed
  Timer? timer;
  ref.onDispose(() => timer?.cancel());
  ref.onCancel(() {
    timer = Timer(const Duration(minutes: 5), () {
      link.close();
    });
  });
  ref.onResume(() => timer?.cancel());
}

// Events
final mortalityProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  _setupKeepAlive(ref);
  final res = await ApiClient.instance.get(ApiEndpoints.mortality);
  return List<dynamic>.from(_extractData(res.data) ?? []);
});

final feedProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  _setupKeepAlive(ref);
  final res = await ApiClient.instance.get(ApiEndpoints.feed);
  return List<dynamic>.from(_extractData(res.data) ?? []);
});

final vaccinationProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  _setupKeepAlive(ref);
  final res = await ApiClient.instance.get(ApiEndpoints.vaccination);
  return List<dynamic>.from(_extractData(res.data) ?? []);
});

final weightProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  _setupKeepAlive(ref);
  final res = await ApiClient.instance.get(ApiEndpoints.weight);
  return List<dynamic>.from(_extractData(res.data) ?? []);
});

// Financials
final salesProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  _setupKeepAlive(ref);
  final res = await ApiClient.instance.get(ApiEndpoints.sales);
  return List<dynamic>.from(_extractData(res.data) ?? []);
});

final expendituresProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  _setupKeepAlive(ref);
  final res = await ApiClient.instance.get(ApiEndpoints.expenditures);
  return List<dynamic>.from(_extractData(res.data) ?? []);
});

final inventoryProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  _setupKeepAlive(ref);
  final sub = ref.watch(subscriptionProvider).value;
  if ((sub?['plan_type'] ?? 'STARTER') == 'STARTER') throw Exception('requires a Professional Plan');

  final res = await ApiClient.instance.get(ApiEndpoints.inventory);
  return List<dynamic>.from(_extractData(res.data) ?? []);
});

final inventoryHistoryProvider = FutureProvider.autoDispose.family<List<dynamic>, String>((ref, itemId) async {
  _setupKeepAlive(ref);
  final res = await ApiClient.instance.get('${ApiEndpoints.inventory}$itemId/history');
  return List<dynamic>.from(_extractData(res.data) ?? []);
});

// Analytics
final dashboardMetricsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  _setupKeepAlive(ref);
  const cacheKey = 'dashboard_metrics';
  try {
    final res = await ApiClient.instance.get(ApiEndpoints.dashboardMetrics);
    final data = Map<String, dynamic>.from(_extractData(res.data) ?? {});
    await HiveCacheService.cacheData(cacheKey, data);
    return data;
  } catch (e) {
    final cached = HiveCacheService.getCachedData(cacheKey);
    if (cached != null) return Map<String, dynamic>.from(cached);
    rethrow;
  }
});

final financialChartProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  _setupKeepAlive(ref);
  final sub = ref.watch(subscriptionProvider).value;
  if ((sub?['plan_type'] ?? 'STARTER') == 'STARTER') throw Exception('requires a Professional Plan');

  final res = await ApiClient.instance.get(ApiEndpoints.financialChart);
  return List<dynamic>.from(_extractData(res.data) ?? []);
});

// Admin
final adminStatsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  _setupKeepAlive(ref);
  final res = await ApiClient.instance.get(ApiEndpoints.adminStats);
  return Map<String, dynamic>.from(_extractData(res.data) ?? {});
});

final adminTransactionsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  _setupKeepAlive(ref);
  final res = await ApiClient.instance.get(ApiEndpoints.adminTransactions);
  return List<dynamic>.from(_extractData(res.data) ?? []);
});

// Logs and People
final alertsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  _setupKeepAlive(ref);
  final sub = ref.watch(subscriptionProvider).value;
  if ((sub?['plan_type'] ?? 'STARTER') == 'STARTER') throw Exception('requires a Professional Plan');

  final res = await ApiClient.instance.get(ApiEndpoints.alerts);
  return List<dynamic>.from(_extractData(res.data) ?? []);
});

final marketPricesProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  _setupKeepAlive(ref);
  final res = await ApiClient.instance.get(ApiEndpoints.marketPrices);
  return List<dynamic>.from(_extractData(res.data) ?? []);
});

final vetConsultationsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  _setupKeepAlive(ref);
  final res = await ApiClient.instance.get(ApiEndpoints.vetConsultations);
  return List<dynamic>.from(_extractData(res.data) ?? []);
});

final biosecurityProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  _setupKeepAlive(ref);
  final res = await ApiClient.instance.get(ApiEndpoints.biosecurity);
  return List<dynamic>.from(_extractData(res.data) ?? []);
});

final auditLogsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  _setupKeepAlive(ref);
  final res = await ApiClient.instance.get('${ApiEndpoints.auditLogs}?action=');
  return List<dynamic>.from(_extractData(res.data) ?? []);
});

final peopleProvider = FutureProvider.autoDispose.family<List<dynamic>, String>((ref, type) async {
  _setupKeepAlive(ref);
  final res = await ApiClient.instance.get(ApiEndpoints.people(type));
  return List<dynamic>.from(_extractData(res.data) ?? []);
});

final profileProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  _setupKeepAlive(ref);
  final res = await ApiClient.instance.get(ApiEndpoints.profile);
  return Map<String, dynamic>.from(_extractData(res.data) ?? {});
});

final resourcesProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  _setupKeepAlive(ref);
  final res = await ApiClient.instance.get(ApiEndpoints.resources);
  return List<dynamic>.from(_extractData(res.data) ?? []);
});

final tasksProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  _setupKeepAlive(ref);
  const cacheKey = 'tasks';
  try {
    final res = await ApiClient.instance.get(ApiEndpoints.tasks);
    final data = List<dynamic>.from(_extractData(res.data) ?? []);
    await HiveCacheService.cacheData(cacheKey, data);
    return data;
  } catch (e) {
    final cached = HiveCacheService.getCachedData(cacheKey);
    if (cached != null) return List<dynamic>.from(cached);
    rethrow;
  }
});

final adminUsersProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  _setupKeepAlive(ref);
  final res = await ApiClient.instance.get('/admin/users');
  return List<dynamic>.from(_extractData(res.data) ?? []);
});

final subscriptionProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  _setupKeepAlive(ref);
  const cacheKey = 'subscription';
  try {
    final res = await ApiClient.instance.get('/billing/my-subscription');
    final data = Map<String, dynamic>.from(_extractData(res.data) ?? {});
    await HiveCacheService.cacheData(cacheKey, data);
    return data;
  } catch (e) {
    final cached = HiveCacheService.getCachedData(cacheKey);
    if (cached != null) return Map<String, dynamic>.from(cached);
    rethrow;
  }
});

final farmsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  _setupKeepAlive(ref);
  final sub = ref.watch(subscriptionProvider).value;
  if ((sub?['plan_type'] ?? 'STARTER') != 'ENTERPRISE') {
    return [];
  }
  final res = await ApiClient.instance.get(ApiEndpoints.farms);
  return List<dynamic>.from(_extractData(res.data) ?? []);
});




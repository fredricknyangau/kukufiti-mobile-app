import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../core/storage/hive_cache_service.dart';
import '../core/models/broiler_models.dart';
import '../core/models/people_models.dart';
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

Future<List<T>> _fetchWithFallback<T>({
  required String endpoint,
  required T Function(Map<String, dynamic>) fromJson,
}) async {
  try {
    final res = await ApiClient.instance.get(endpoint);
    final data = List<dynamic>.from(_extractData(res.data) ?? []);
    await HiveCacheService.cacheData(endpoint, data);
    return data.map((e) => fromJson(Map<String, dynamic>.from(e))).toList();
  } catch (e) {
    final cachedData = HiveCacheService.getCachedData(endpoint);
    if (cachedData != null) {
      final data = List<dynamic>.from(cachedData);
      return data.map((e) => fromJson(Map<String, dynamic>.from(e))).toList();
    }
    rethrow;
  }
}

Future<List<dynamic>> _fetchListWithFallback({
  required String endpoint,
}) async {
  try {
    final res = await ApiClient.instance.get(endpoint);
    final data = List<dynamic>.from(_extractData(res.data) ?? []);
    await HiveCacheService.cacheData(endpoint, data);
    return data;
  } catch (e) {
    final cachedData = HiveCacheService.getCachedData(endpoint);
    if (cachedData != null) return List<dynamic>.from(cachedData);
    rethrow;
  }
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
final mortalityProvider = FutureProvider.autoDispose<List<MortalityRecord>>((ref) async {
  _setupKeepAlive(ref);
  return _fetchWithFallback(
    endpoint: ApiEndpoints.mortality,
    fromJson: MortalityRecord.fromJson,
  );
});

final feedProvider = FutureProvider.autoDispose<List<FeedRecord>>((ref) async {
  _setupKeepAlive(ref);
  return _fetchWithFallback(
    endpoint: ApiEndpoints.feed,
    fromJson: FeedRecord.fromJson,
  );
});

final vaccinationProvider = FutureProvider.autoDispose<List<VaccinationRecord>>((ref) async {
  _setupKeepAlive(ref);
  return _fetchWithFallback(
    endpoint: ApiEndpoints.vaccination,
    fromJson: VaccinationRecord.fromJson,
  );
});

final weightProvider = FutureProvider.autoDispose<List<WeightRecord>>((ref) async {
  _setupKeepAlive(ref);
  return _fetchWithFallback(
    endpoint: ApiEndpoints.weight,
    fromJson: WeightRecord.fromJson,
  );
});

// Financials
final salesProvider = FutureProvider.autoDispose<List<SaleRecord>>((ref) async {
  _setupKeepAlive(ref);
  return _fetchWithFallback(
    endpoint: ApiEndpoints.sales,
    fromJson: SaleRecord.fromJson,
  );
});

final expendituresProvider = FutureProvider.autoDispose<List<Expenditure>>((ref) async {
  _setupKeepAlive(ref);
  return _fetchWithFallback(
    endpoint: ApiEndpoints.expenditures,
    fromJson: Expenditure.fromJson,
  );
});

final inventoryProvider = FutureProvider.autoDispose<List<InventoryItem>>((ref) async {
  _setupKeepAlive(ref);
  final planDetails = ref.watch(planDetailsProvider).value;
  final features = List<String>.from(planDetails?['features'] ?? []);
  
  final profile = ref.watch(profileProvider).value;
  if (profile?.isAdmin != true && !features.contains('inventory')) {
    throw Exception('Inventory requires a Professional Plan');
  }

  return _fetchWithFallback(
    endpoint: ApiEndpoints.inventory,
    fromJson: InventoryItem.fromJson,
  );
});

final inventoryHistoryProvider = FutureProvider.autoDispose.family<List<InventoryHistoryRecord>, String>((ref, itemId) async {
  _setupKeepAlive(ref);
  return _fetchWithFallback(
    endpoint: '${ApiEndpoints.inventory}$itemId/history',
    fromJson: InventoryHistoryRecord.fromJson,
  );
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
  final planDetails = ref.watch(planDetailsProvider).value;
  final features = List<String>.from(planDetails?['features'] ?? []);
  
  final profile = ref.watch(profileProvider).value;
  if (profile?.isAdmin != true && !features.contains('financials')) {
    throw Exception('Financial Analytics require a Professional Plan');
  }

  return _fetchListWithFallback(endpoint: ApiEndpoints.financialChart);
});

final benchmarkingProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  _setupKeepAlive(ref);
  const cacheKey = 'benchmarking_metrics';
  try {
    final res = await ApiClient.instance.get(ApiEndpoints.benchmarking);
    final data = Map<String, dynamic>.from(_extractData(res.data) ?? {});
    await HiveCacheService.cacheData(cacheKey, data);
    return data;
  } catch (e) {
    final cached = HiveCacheService.getCachedData(cacheKey);
    if (cached != null) return Map<String, dynamic>.from(cached);
    rethrow;
  }
});

// Admin
final adminStatsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  _setupKeepAlive(ref);
  const cacheKey = 'admin_stats';
  try {
    final res = await ApiClient.instance.get(ApiEndpoints.adminStats);
    final data = Map<String, dynamic>.from(_extractData(res.data) ?? {});
    await HiveCacheService.cacheData(cacheKey, data);
    return data;
  } catch (e) {
    final cached = HiveCacheService.getCachedData(cacheKey);
    if (cached != null) return Map<String, dynamic>.from(cached);
    rethrow;
  }
});

final adminTransactionsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  _setupKeepAlive(ref);
  return _fetchListWithFallback(endpoint: ApiEndpoints.adminTransactions);
});

// Logs and People
final alertsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  _setupKeepAlive(ref);
  final planDetails = ref.watch(planDetailsProvider).value;
  final features = List<String>.from(planDetails?['features'] ?? []);
  
  final profile = ref.watch(profileProvider).value;
  if (profile?.isAdmin != true && !features.contains('alerts')) {
    throw Exception('Alerts require a Professional Plan');
  }

  return _fetchListWithFallback(endpoint: ApiEndpoints.alerts);
});

final marketPricesProvider = FutureProvider.autoDispose<List<MarketPrice>>((ref) async {
  _setupKeepAlive(ref);
  final planDetails = ref.watch(planDetailsProvider).value;
  final features = List<String>.from(planDetails?['features'] ?? []);
  
  final profile = ref.watch(profileProvider).value;
  if (profile?.isAdmin != true && !features.contains('market_prices')) {
    throw Exception('Market Prices require a Professional Plan');
  }

  return _fetchWithFallback(
    endpoint: ApiEndpoints.marketPrices,
    fromJson: MarketPrice.fromJson,
  );
});

final vetConsultationsProvider = FutureProvider.autoDispose<List<VetConsultation>>((ref) async {
  _setupKeepAlive(ref);
  final planDetails = ref.watch(planDetailsProvider).value;
  final features = List<String>.from(planDetails?['features'] ?? []);
  
  final profile = ref.watch(profileProvider).value;
  if (profile?.isAdmin != true && !features.contains('vet_consults')) {
    throw Exception('Vet Consultations require a Professional Plan');
  }

  return _fetchWithFallback(
    endpoint: ApiEndpoints.vetConsultations,
    fromJson: VetConsultation.fromJson,
  );
});

final biosecurityProvider = FutureProvider.autoDispose<List<BiosecurityCheck>>((ref) async {
  _setupKeepAlive(ref);
  return _fetchWithFallback(
    endpoint: ApiEndpoints.biosecurity,
    fromJson: BiosecurityCheck.fromJson,
  );
});

final auditLogsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  _setupKeepAlive(ref);
  final planDetails = ref.watch(planDetailsProvider).value;
  final features = List<String>.from(planDetails?['features'] ?? []);
  
  final profile = ref.watch(profileProvider).value;
  if (profile?.isAdmin != true && !features.contains('audit_logs')) {
    throw Exception('Audit Logs require an Enterprise Plan');
  }

  return _fetchListWithFallback(endpoint: '${ApiEndpoints.auditLogs}?action=');
});

// People specific providers
final suppliersProvider = FutureProvider.autoDispose<List<Supplier>>((ref) async {
  _setupKeepAlive(ref);
  return _fetchWithFallback(
    endpoint: ApiEndpoints.people('supplier'),
    fromJson: Supplier.fromJson,
  );
});

final customersProvider = FutureProvider.autoDispose<List<Customer>>((ref) async {
  _setupKeepAlive(ref);
  return _fetchWithFallback(
    endpoint: ApiEndpoints.people('customer'),
    fromJson: Customer.fromJson,
  );
});

final employeesProvider = FutureProvider.autoDispose<List<Employee>>((ref) async {
  _setupKeepAlive(ref);
  return _fetchWithFallback(
    endpoint: ApiEndpoints.people('employee'),
    fromJson: Employee.fromJson,
  );
});

final profileProvider = FutureProvider.autoDispose<User>((ref) async {
  _setupKeepAlive(ref);
  const cacheKey = 'profile_data';
  try {
    final res = await ApiClient.instance.get(ApiEndpoints.profile);
    final data = Map<String, dynamic>.from(_extractData(res.data) ?? {});
    await HiveCacheService.cacheData(cacheKey, data);
    return User.fromJson(data);
  } catch (e) {
    final cached = HiveCacheService.getCachedData(cacheKey);
    if (cached != null) return User.fromJson(Map<String, dynamic>.from(cached));
    rethrow;
  }
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
    final res = await ApiClient.instance.get(ApiEndpoints.mySubscription);
    final data = Map<String, dynamic>.from(_extractData(res.data) ?? {});
    await HiveCacheService.cacheData(cacheKey, data);
    return data;
  } catch (e) {
    final cached = HiveCacheService.getCachedData(cacheKey);
    if (cached != null) return Map<String, dynamic>.from(cached);
    rethrow;
  }
});

final planDetailsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  _setupKeepAlive(ref);
  const cacheKey = 'plan_details';
  try {
    final res = await ApiClient.instance.get(ApiEndpoints.planDetails);
    final data = Map<String, dynamic>.from(_extractData(res.data) ?? {});
    await HiveCacheService.cacheData(cacheKey, data);
    return data;
  } catch (e) {
    final cached = HiveCacheService.getCachedData(cacheKey);
    if (cached != null) return Map<String, dynamic>.from(cached);
    rethrow;
  }
});

final dailyChecksProvider = FutureProvider.autoDispose.family<List<DailyCheck>, String>((ref, flockId) async {
  _setupKeepAlive(ref);
  return _fetchWithFallback(
    endpoint: '${ApiEndpoints.dailyChecks}$flockId',
    fromJson: DailyCheck.fromJson,
  );
});

// AI & Tasks
final aiAdvisoryProvider = FutureProvider.autoDispose.family<AIResponse, Map<String, dynamic>>((ref, params) async {
  _setupKeepAlive(ref);
  final planDetails = ref.watch(planDetailsProvider).value;
  final features = List<String>.from(planDetails?['features'] ?? []);
  
  final profile = ref.watch(profileProvider).value;
  if (profile?.isAdmin != true && !features.contains('ai_advisory')) {
    throw Exception('AI Advisory requires a Professional Plan');
  }

  final endpoint = params['endpoint'] as String;
  final data = params['data'] as Map<String, dynamic>;
  
  final res = await ApiClient.instance.post(endpoint, data: data);
  return AIResponse.fromJson(Map<String, dynamic>.from(_extractData(res.data)));
});

class TaskNotifier extends AsyncNotifier<List<ScheduledTask>> {
  @override
  FutureOr<List<ScheduledTask>> build() async {
    _setupKeepAlive(ref);
    return _fetchWithFallback(
      endpoint: ApiEndpoints.tasks,
      fromJson: ScheduledTask.fromJson,
    );
  }

  Future<void> createTask(Map<String, dynamic> data) async {
    await ApiClient.instance.post(ApiEndpoints.tasks, data: data);
    ref.invalidateSelf();
  }

  Future<void> updateTask(String id, Map<String, dynamic> data) async {
    await ApiClient.instance.put('${ApiEndpoints.tasks}$id', data: data);
    ref.invalidateSelf();
  }

  Future<void> deleteTask(String id) async {
    await ApiClient.instance.delete('${ApiEndpoints.tasks}$id');
    ref.invalidateSelf();
  }
}

final taskManagementProvider = AsyncNotifierProvider<TaskNotifier, List<ScheduledTask>>(() {
  return TaskNotifier();
});

final farmsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  _setupKeepAlive(ref);
  final planDetails = ref.watch(planDetailsProvider).value;
  final features = List<String>.from(planDetails?['features'] ?? []);
  
  final profile = ref.watch(profileProvider).value;
  if (profile?.isAdmin != true && !features.contains('multi_farm')) {
    return [];
  }
  final res = await ApiClient.instance.get(ApiEndpoints.farms);
  return List<dynamic>.from(_extractData(res.data) ?? []);
});

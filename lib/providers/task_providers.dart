// task_providers.dart — scheduled tasks with full CRUD notifier
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../core/storage/hive_cache_service.dart';
import '../core/models/broiler_models.dart';
import '_provider_utils.dart';

final tasksProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  setupKeepAlive(ref);
  const cacheKey = 'tasks';
  try {
    final res = await ApiClient.instance.get(ApiEndpoints.tasks);
    final data = List<dynamic>.from(extractData(res.data) ?? []);
    await HiveCacheService.cacheData(cacheKey, data);
    return data;
  } catch (e) {
    final cached = HiveCacheService.getCachedData(cacheKey);
    if (cached != null) return List<dynamic>.from(cached);
    rethrow;
  }
});

class TaskNotifier extends AsyncNotifier<List<ScheduledTask>> {
  @override
  FutureOr<List<ScheduledTask>> build() async {
    setupKeepAlive(ref);
    return fetchWithFallback(
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

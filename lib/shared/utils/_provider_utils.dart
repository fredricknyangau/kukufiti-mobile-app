// _provider_utils.dart — shared utilities used by all provider files
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/storage/hive_cache_service.dart';
import 'package:mobile/features/auth_management/presentation/providers/auth_provider.dart';

/// Extracts the actual list/map from common API response wrappers:
/// ``{ "data": [...] }``, ``{ "items": [...] }``, or a bare ``[...]``.
dynamic extractData(dynamic responseData) {
  if (responseData is Map<String, dynamic>) {
    if (responseData.containsKey('data')) return responseData['data'];
    if (responseData.containsKey('items')) return responseData['items'];
  }
  return responseData;
}

/// Fetch a typed list with Hive cache fallback on network error.
Future<List<T>> fetchWithFallback<T>({
  required String endpoint,
  required T Function(Map<String, dynamic>) fromJson,
}) async {
  try {
    final res = await ApiClient.instance.get(endpoint);
    final data = List<dynamic>.from(extractData(res.data) ?? []);
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

/// Fetch a raw dynamic list with Hive cache fallback on network error.
Future<List<dynamic>> fetchListWithFallback({required String endpoint}) async {
  try {
    final res = await ApiClient.instance.get(endpoint);
    final data = List<dynamic>.from(extractData(res.data) ?? []);
    await HiveCacheService.cacheData(endpoint, data);
    return data;
  } catch (e) {
    final cachedData = HiveCacheService.getCachedData(endpoint);
    if (cachedData != null) return List<dynamic>.from(cachedData);
    rethrow;
  }
}

/// Keeps the provider data alive for 5 minutes after its last subscriber
/// leaves.  Immediately closes on logout to prevent cross-account data leaks.
void setupKeepAlive(Ref ref) {
  final link = ref.keepAlive();

  ref.listen<AuthState>(
    authProvider,
    (prev, next) {
      if (!next.isAuthenticated) link.close();
    },
  );

  Timer? timer;
  ref.onDispose(() => timer?.cancel());
  ref.onCancel(() {
    timer = Timer(const Duration(minutes: 5), () => link.close());
  });
  ref.onResume(() => timer?.cancel());
}

// shared utilities used by all provider files
import 'dart:async';
import 'package:flutter/foundation.dart';
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

/// Fetch a typed list with immediate Hive cache return if available,
/// while refreshing the network in the background.
Future<List<T>> fetchWithFallback<T>({
  required String endpoint,
  required T Function(Map<String, dynamic>) fromJson,
}) async {
  // 1. Check cache first for "Immediate" feel
  final cachedData = HiveCacheService.getCachedData(endpoint);
  if (cachedData != null) {
    // Refresh background
    unawaited(ApiClient.instance.get(endpoint).then((res) async {
      final data = List<dynamic>.from(extractData(res.data) ?? []);
      await HiveCacheService.cacheData(endpoint, data);
    }).catchError((e) {
      debugPrint('Background Refresh Failed for $endpoint: $e');
    }));

    final data = List<dynamic>.from(cachedData);
    return data.map((e) => fromJson(Map<String, dynamic>.from(e))).toList();
  }

  // 2. No cache, must wait for network
  try {
    final res = await ApiClient.instance.get(endpoint);
    final data = List<dynamic>.from(extractData(res.data) ?? []);
    await HiveCacheService.cacheData(endpoint, data);
    return data.map((e) => fromJson(Map<String, dynamic>.from(e))).toList();
  } catch (e) {
    // If we get here and have no cache, we must rethrow
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

/// A specialized helper for Notifiers to implement "Cache First, Network Second" loading.
/// This allows the UI to show data IMMEDIATELY from the database upon app open.
Future<void> fetchWithImmediateCache<T>({
  required String endpoint,
  required T Function(Map<String, dynamic>) fromJson,
  required void Function(List<T> data, {required bool isLoading}) onUpdate,
  required void Function(String error) onError,
}) async {
  // 1. Try to load from cache first
  try {
    final cachedData = HiveCacheService.getCachedData(endpoint);
    if (cachedData != null) {
      final data = List<dynamic>.from(cachedData)
          .map((e) => fromJson(Map<String, dynamic>.from(e)))
          .toList();
      onUpdate(data, isLoading: true); // Still loading fresh data
    }
  } catch (e) {
    debugPrint('Hydration: Cache read failed for $endpoint: $e');
  }

  // 2. Fetch from network
  try {
    final res = await ApiClient.instance.get(endpoint);
    final dataList = List<dynamic>.from(extractData(res.data) ?? []);
    
    // Update cache
    await HiveCacheService.cacheData(endpoint, dataList);
    
    final data = dataList
        .map((e) => fromJson(Map<String, dynamic>.from(e)))
        .toList();
        
    onUpdate(data, isLoading: false);
  } catch (e) {
    // If we already have cached data in the state, don't show an error
    // unless it's a completely empty state.
    onError(e.toString());
  }
}

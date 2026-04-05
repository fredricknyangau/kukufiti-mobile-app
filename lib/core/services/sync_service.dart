import 'package:hive_flutter/hive_flutter.dart';
import 'package:dio/dio.dart';
import 'dart:async';
import '../network/api_client.dart';
import '../utils/toast_service.dart';
import 'package:flutter/material.dart';

class SyncService {
  static final _box = Hive.box('offline_sync_queue');

  static void startAutoSync(BuildContext context) {
    // Sync immediately on startup / login
    syncPending(context);

    Timer.periodic(const Duration(minutes: 5), (timer) {
      if (context.mounted) {
        syncPending(context);
      } else {
        timer.cancel();
      }
    });
  }

  static Future<void> enqueueOperation({
    required String endpoint,
    required String method,
    required Map<String, dynamic> data,
  }) async {
    final ops = _box.get('queue', defaultValue: []) as List;
    final newOp = {
      'endpoint': endpoint,
      'method': method,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
      'retryCount': 0,
      'nextRetryAt': DateTime.now().toIso8601String(), // Immediate first attempt
    };
    ops.add(newOp);
    await _box.put('queue', ops);
  }

  static List<Map<String, dynamic>> getPendingOperations() {
    final ops = _box.get('queue', defaultValue: []) as List;
    return ops.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<void> syncPending(BuildContext context) async {
    final ops = getPendingOperations();
    if (ops.isEmpty) return;

    int successCount = 0;
    List<Map<String, dynamic>> updatedQueue = [];
    final now = DateTime.now();

    for (var op in ops) {
      final endpoint = op['endpoint'] as String?;
      final method = op['method'] as String?;
      final data = op['data'] != null ? Map<String, dynamic>.from(op['data']) : <String, dynamic>{};
      int retryCount = (op['retryCount'] ?? 0) as int;
      final nextRetryAtStr = op['nextRetryAt'] as String?;
      
      if (endpoint == null || method == null) continue;

      // Skip if it is not time to retry yet
      if (nextRetryAtStr != null) {
        final nextRetryAt = DateTime.parse(nextRetryAtStr);
        if (now.isBefore(nextRetryAt)) {
          updatedQueue.add(op);
          continue;
        }
      }

      try {
        if (method == 'POST') {
          await ApiClient.instance.post(endpoint, data: data);
        } else if (method == 'PUT') {
          await ApiClient.instance.put(endpoint, data: data);
        } else if (method == 'DELETE') {
          await ApiClient.instance.delete(endpoint);
        }
        successCount++;
        // If success, we don't add to updatedQueue
      } catch (e) {
        bool shouldDrop = false;
        
        // 4xx errors (except 429) are usually client-side bugs/validation failures. Drop them.
        if (e is DioException && e.response?.statusCode != null) {
          final code = e.response!.statusCode!;
          if (code >= 400 && code < 500 && code != 429) {
            debugPrint('SyncService: Dropping invalid operation ($code): $endpoint');
            shouldDrop = true;
          }
        }

        if (!shouldDrop) {
          retryCount++;
          if (retryCount >= 10) { // Max 10 retries
            debugPrint('SyncService: Dropping operation after 10 failures: $endpoint');
          } else {
            // Exponential Backoff: 2^retryCount * 1 minute
            final delayMinutes = (1 << (retryCount - 1)); 
            final nextRetry = now.add(Duration(minutes: delayMinutes));
            
            op['retryCount'] = retryCount;
            op['nextRetryAt'] = nextRetry.toIso8601String();
            updatedQueue.add(op);
            debugPrint('SyncService: Scheduling retry #$retryCount for $endpoint at $nextRetry');
          }
        }
      }
    }

    // Replace the queue with updated state
    await _box.put('queue', updatedQueue);

    if (context.mounted && successCount > 0) {
      ToastService.showSuccess(context, 'Synced $successCount operations successfully');
    }
  }
}

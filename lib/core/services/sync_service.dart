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
      'retryCount': 0, // Track retries
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
    List<Map<String, dynamic>> failedOps = [];
    const int maxRetries = 3;

    for (var op in ops) {
      final endpoint = op['endpoint'] as String?;
      final method = op['method'] as String?;
      final data = op['data'] != null ? Map<String, dynamic>.from(op['data']) : <String, dynamic>{};
      int retryCount = (op['retryCount'] ?? 0) as int;

      if (endpoint == null || method == null) continue;

      try {
        if (method == 'POST') {
          await ApiClient.instance.post(endpoint, data: data);
        } else if (method == 'PUT') {
          await ApiClient.instance.put(endpoint, data: data);
        } else if (method == 'DELETE') {
          await ApiClient.instance.delete(endpoint);
        }
        successCount++;
      } catch (e) {
        // Handle validation errors (400) or max retries
        bool shouldDrop = false;
        if (e is DioException && e.response?.statusCode == 400) {
          debugPrint('SyncService: Dropping invalid operation (400 Bad Request): $endpoint');
          shouldDrop = true;
        } else {
          retryCount++;
          if (retryCount >= maxRetries) {
            debugPrint('SyncService: Dropping operation after $maxRetries failures: $endpoint');
            shouldDrop = true;
          }
        }

        if (!shouldDrop) {
          op['retryCount'] = retryCount;
          failedOps.add(op);
        }
      }
    }

    // Update queue with only failed ones that haven't reached retry limit
    await _box.put('queue', failedOps);

    if (context.mounted && successCount > 0) {
      ToastService.showSuccess(context, 'Synced $successCount operations successfully');
    }
    
    // Only show error toast if there are items left in the queue (failed but retriable)
    if (failedOps.isNotEmpty && context.mounted) {
       ToastService.showError(context, '${failedOps.length} operations waiting to retry sync');
    }
  }
}

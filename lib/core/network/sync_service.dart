import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'api_client.dart';

class SyncRequest {
  final String path;
  final String method;
  final dynamic data;
  final Map<String, dynamic>? queryParameters;
  final DateTime timestamp;

  SyncRequest({
    required this.path,
    required this.method,
    this.data,
    this.queryParameters,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'path': path,
    'method': method,
    'data': data,
    'queryParameters': queryParameters,
    'timestamp': timestamp.toIso8601String(),
  };

  factory SyncRequest.fromJson(Map<String, dynamic> json) => SyncRequest(
    path: json['path'],
    method: json['method'],
    data: json['data'],
    queryParameters: json['queryParameters'],
    timestamp: DateTime.parse(json['timestamp']),
  );
}

class SyncService {
  static final _box = Hive.box('offline_sync_queue');
  static bool _isSyncing = false;

  static Future<void> queueRequest(RequestOptions options) async {
    final request = SyncRequest(
      path: options.path,
      method: options.method,
      data: options.data,
      queryParameters: options.queryParameters,
      timestamp: DateTime.now(),
    );
    
    final id = options.path + options.method + DateTime.now().millisecondsSinceEpoch.toString();
    await _box.put(id, jsonEncode(request.toJson()));
    debugPrint('SyncService: Queued ${options.method} ${options.path}');
  }

  static Future<void> processQueue() async {
    if (_isSyncing || _box.isEmpty) return;
    _isSyncing = true;
    
    debugPrint('SyncService: Processing ${_box.length} queued requests...');
    
    final keys = _box.keys.toList();
    for (var key in keys) {
      final raw = _box.get(key);
      if (raw == null) continue;
      
      final request = SyncRequest.fromJson(jsonDecode(raw));
      
      try {
        final dio = ApiClient.instance;
        await dio.request(
          request.path,
          data: request.data,
          queryParameters: request.queryParameters,
          options: Options(method: request.method),
        );
        
        await _box.delete(key);
        debugPrint('SyncService: Successfully synced ${request.method} ${request.path}');
      } catch (e) {
        debugPrint('SyncService: Failed to sync ${request.method} ${request.path}: $e');
        // Stop processing on first error to preserve order if needed, 
        // or just continue for independent mutations.
        break; 
      }
    }
    
    _isSyncing = false;
  }
}

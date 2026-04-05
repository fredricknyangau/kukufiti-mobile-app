import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import '../storage/secure_storage_service.dart';
import 'sync_service.dart';

/// Optimized HTTP client with robust timeout and non-blocking interceptor.
class ApiClient {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiUrl.endsWith('/') 
          ? AppConfig.apiUrl 
          : '${AppConfig.apiUrl}/',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  static bool _initialized = false;

  static Dio get instance {
    if (!_initialized) {
      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            try {
              // Wrap token fetch in a timeout to prevent SecureStorage hangs
              // from blocking the entire network request.
              final token = await SecureStorageService.getAuthToken()
                  .timeout(const Duration(seconds: 2), onTimeout: () => null);
                  
              if (token != null && token.isNotEmpty) {
                options.headers['Authorization'] = 'Bearer $token';
              }
            } catch (e) {
              debugPrint('ApiClient: Token fetch failed, proceeding without token: $e');
            }
            return handler.next(options);
          },
          onError: (DioException e, handler) async {
            debugPrint('API Error [${e.requestOptions.method} ${e.requestOptions.path}]: ${e.type} - ${e.message}');
            
            // Mutation retry logic for offline
            if (e.type == DioExceptionType.connectionTimeout || 
                e.type == DioExceptionType.sendTimeout ||
                e.type == DioExceptionType.receiveTimeout ||
                e.type == DioExceptionType.connectionError) {
              
              if (e.requestOptions.method != 'GET') {
                await SyncService.queueRequest(e.requestOptions);
                // Return a fake success response or specific error to the UI
                return handler.resolve(Response(
                  requestOptions: e.requestOptions,
                  statusCode: 202, // Accepted for sync
                  data: {'status': 'queued', 'message': 'Offline: Request queued for sync.'},
                ));
              }
            }

            if (e.requestOptions.data != null) {
              debugPrint('Request Data: ${e.requestOptions.data}');
            }
            if (e.response != null) {
              debugPrint('Response Data: ${e.response?.data}');
            }
            if (e.response?.statusCode == 401) {
              await SecureStorageService.deleteAuthToken();
            }
            return handler.next(e);
          },
        ),
      );
      _initialized = true;
    }
    return _dio;
  }
}

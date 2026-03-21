import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// App-wide configuration values that are set via build-time defines.
class AppConfig {
  /// The base API URL used across the app.
  static String get apiUrl {
    const envApiUrl = String.fromEnvironment('API_URL', defaultValue: '');

    if (envApiUrl.isNotEmpty) return envApiUrl;

    // Check Hive box for a saved URL (allows configuration in-app)
    try {
      final box = Hive.box('offline_cache');
      final savedUrl = box.get('API_URL');
      if (savedUrl != null && savedUrl.toString().isNotEmpty) {
        return savedUrl.toString();
      }
    } catch (e) {
      debugPrint('AppConfig: Failed to read from Hive: $e');
    }

    // In release mode, if not set, return empty string or fallback so main.dart can catch it.
    return 'https://kukufiti-backend.onrender.com/api/v1';
  }

  /// Returns `true` when the app is currently using the local development API URL.
  static bool get isUsingDefaultApiUrl {
    // If we have a saved URL in Hive, we are NOT using the default build-time fallback.
    try {
      final box = Hive.box('offline_cache');
      final savedUrl = box.get('API_URL');
      if (savedUrl != null && savedUrl.toString().isNotEmpty) {
        return false;
      }
    } catch (_) {}

    return apiUrl == 'http://192.168.100.45:8000/api/v1' ||
        apiUrl == 'http://10.0.2.2:8000/api/v1';
  }
}

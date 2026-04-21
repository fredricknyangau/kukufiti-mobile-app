import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// App-wide configuration values that are set via build-time defines.
class AppConfig {
  /// The base API URL used across the app.
  static String get apiUrl {
    const envApiUrl = String.fromEnvironment('API_URL', defaultValue: '');

    if (envApiUrl.isNotEmpty) return envApiUrl;

    // Check Hive box for a saved URL (allows configuration in-app for dev)
    try {
      final box = Hive.box('offline_cache');
      final savedUrl = box.get('API_URL');
      if (savedUrl != null && savedUrl.toString().isNotEmpty) {
        return savedUrl.toString();
      }
    } catch (e) {
      debugPrint('AppConfig: Failed to read from Hive: $e');
    }

    // Default to the correct development URL if no environment is provided
    return 'http://10.0.2.2:8080/api/v1';
  }

  /// Returns `true` only if the app is pointed at a known local-only dev URL
  /// that would be unreachable in production. This is used by [ConfigErrorApp]
  /// to prompt the user to enter the correct backend URL before proceeding.
  static bool get isUsingDefaultApiUrl {
    // If the user has saved a custom URL in Hive, always trust it.
    try {
      final box = Hive.box('offline_cache');
      final savedUrl = box.get('API_URL');
      if (savedUrl != null && savedUrl.toString().isNotEmpty) {
        return false;
      }
    } catch (_) {}

    return apiUrl.contains('10.0.2.2') || apiUrl.contains('192.168.');
  }
}

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

    // Fall back to the production Render URL. This is intentional — it means
    // `isUsingDefaultApiUrl` will return false and the ConfigErrorApp overlay
    // will NOT show. The app will connect to the hosted backend directly.
    return 'https://kukufiti-backend.onrender.com/api/v1';
  }

  /// Returns `true` only if the app is pointed at a known local-only dev URL
  /// that would be unreachable in production (e.g. a private LAN IP or Android
  /// emulator loopback). This is used by [ConfigErrorApp] to prompt the user
  /// to enter the correct backend URL before proceeding.
  ///
  /// NOTE: The production Render URL fallback is NOT flagged here — it is a
  /// valid public URL and the app should connect to it normally.
  static bool get isUsingDefaultApiUrl {
    // If the user has saved a custom URL in Hive, always trust it.
    try {
      final box = Hive.box('offline_cache');
      final savedUrl = box.get('API_URL');
      if (savedUrl != null && savedUrl.toString().isNotEmpty) {
        return false;
      }
    } catch (_) {}

    // Only flag legacy local-only development URLs.
    return apiUrl == 'http://192.168.100.45:8000/api/v1' ||
        apiUrl == 'http://10.0.2.2:8000/api/v1';
  }
}

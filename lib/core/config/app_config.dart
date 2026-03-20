import 'package:flutter/foundation.dart';

/// App-wide configuration values that are set via build-time defines.
class AppConfig {


  /// The base API URL used across the app.
  static String get apiUrl {
    const envApiUrl = String.fromEnvironment(
      'API_URL',
      defaultValue: '',
    );

    if (envApiUrl.isNotEmpty) return envApiUrl;

    // In release mode, if not set, return empty string or fallback so main.dart can catch it.

    return kIsWeb ? 'http://localhost:8000/api/v1' : 'http://10.0.2.2:8000/api/v1';
  }

  /// Returns `true` when the app is currently using the local development API URL.
  static bool get isUsingDefaultApiUrl => 
      apiUrl == 'http://localhost:8000/api/v1' || 
      apiUrl == 'http://10.0.2.2:8000/api/v1';
}

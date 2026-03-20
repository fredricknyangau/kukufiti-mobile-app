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

    if (kReleaseMode) {
      throw StateError(
        'API_URL is not set. Please build the app with `--dart-define=API_URL=<your backend url>`.',
      );
    }

    return kIsWeb ? 'http://localhost:8000/api/v1' : 'http://10.0.2.2:8000/api/v1';
  }

  /// Returns `true` when the app is currently using the local development API URL.
  static bool get isUsingDefaultApiUrl => 
      apiUrl == 'http://localhost:8000/api/v1' || 
      apiUrl == 'http://10.0.2.2:8000/api/v1';
}

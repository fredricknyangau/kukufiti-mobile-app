import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// App-wide configuration and build information
class AppConfig {
  static final AppConfig _instance = AppConfig._internal();
  static late PackageInfo _packageInfo;

  factory AppConfig() {
    return _instance;
  }

  AppConfig._internal();

  /// Initialize app config - call this in main()
  static Future<void> initialize() async {
    _packageInfo = await PackageInfo.fromPlatform();
  }

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

  static String get googleClientId {
    return const String.fromEnvironment('GOOGLE_CLIENT_ID');
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

  /// Get app version from package_info_plus
  static String get appVersion => _packageInfo.version;

  /// Get build number from package_info_plus
  static String get buildNumber => _packageInfo.buildNumber;

  /// Get full version string (version + build number)
  static String get fullVersion => '$appVersion+$buildNumber';

  /// Get app package name
  static String get packageName => _packageInfo.packageName;

  /// Get app name
  static String get appName => _packageInfo.appName;

  /// Check if app is running in debug mode
  static bool get isDebug => kDebugMode;

  /// Check if app is running in profile mode
  static bool get isProfile => kProfileMode;

  /// Check if app is running in release mode
  static bool get isRelease => kReleaseMode;

  /// Get build mode as string
  static String get buildMode {
    if (isDebug) return 'debug';
    if (isProfile) return 'profile';
    return 'release';
  }

  /// Build information map (useful for debugging and logging)
  static Map<String, String> get buildInfo => {
    'version': appVersion,
    'buildNumber': buildNumber,
    'fullVersion': fullVersion,
    'packageName': packageName,
    'appName': appName,
    'buildMode': buildMode,
    'apiUrl': apiUrl,
    'platform': _getPlatform(),
  };

  static String _getPlatform() {
    if (defaultTargetPlatform == TargetPlatform.android) return 'Android';
    if (defaultTargetPlatform == TargetPlatform.iOS) return 'iOS';
    return 'Unknown';
  }

  /// Print build information to console (useful for debugging)
  static void printBuildInfo() {
    debugPrint('''
    ╔════════════════════════════════════════════════════════╗
    ║         KukuFiti - Build Information                  ║
    ╠════════════════════════════════════════════════════════╣
    ║ App:              ${appName.padRight(40)} ║
    ║ Version:          ${appVersion.padRight(40)} ║
    ║ Build Number:     ${buildNumber.padRight(40)} ║
    ║ Full Version:     ${fullVersion.padRight(40)} ║
    ║ Build Mode:       ${buildMode.padRight(40)} ║
    ║ Platform:         ${_getPlatform().padRight(40)} ║
    ║ API URL:          ${_sanitizeUrl(apiUrl).padRight(40)} ║
    ║ Package:          ${packageName.padRight(40)} ║
    ╚════════════════════════════════════════════════════════╝
    ''');
  }

  static String _sanitizeUrl(String url) {
    // Show only host for security
    try {
      final uri = Uri.parse(url);
      return uri.host.isNotEmpty ? uri.host : url.substring(0, 30);
    } catch (_) {
      return url.length > 30 ? '${url.substring(0, 30)}...' : url;
    }
  }

  /// Update API URL at runtime (useful for development)
  static Future<void> setApiUrl(String url) async {
    try {
      final box = Hive.box('offline_cache');
      await box.put('API_URL', url);
      debugPrint('API URL updated to: $url');
    } catch (e) {
      debugPrint('Failed to update API URL: $e');
      rethrow;
    }
  }

  /// Reset API URL to default
  static Future<void> resetApiUrl() async {
    try {
      final box = Hive.box('offline_cache');
      await box.delete('API_URL');
      debugPrint('API URL reset to default');
    } catch (e) {
      debugPrint('Failed to reset API URL: $e');
      rethrow;
    }
  }
}

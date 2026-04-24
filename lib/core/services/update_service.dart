import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mobile/core/config/app_config.dart';

class UpdateInfo {
  final bool isUpdateAvailable;
  final String currentVersion;
  final String latestVersion;
  final String downloadUrl;
  final String releaseNotes;

  const UpdateInfo({
    required this.isUpdateAvailable,
    required this.currentVersion,
    required this.latestVersion,
    required this.downloadUrl,
    required this.releaseNotes,
  });
}

class UpdateService {
  // ⚠️  IMPORTANT: These must match the GitHub account and repository
  //    where APK release assets are published. If the repo name is wrong,
  //    the update check will silently return null and users won't see updates.
  //    Verify at: https://github.com/$_owner/$_repo/releases
  static const String _owner = 'fredricknyangau';
  static const String _repo  = 'kukufiti-mobile-app';

  static const String _apiUrl =
      'https://api.github.com/repos/$_owner/$_repo/releases/latest';

  /// Fetches latest release from GitHub and compares with installed version.
  /// Returns null if the check fails (no internet, API error, etc.)
  static Future<UpdateInfo?> checkForUpdate() async {
    try {
      // Get the currently installed app version
      final currentVersion = AppConfig.fullVersion; // e.g. "1.0.0+1"

      // Call GitHub API
      final response = await http
          .get(
            Uri.parse(_apiUrl),
            headers: {'Accept': 'application/vnd.github+json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return null;

      final data = json.decode(response.body) as Map<String, dynamic>;

      // Tag name from GitHub — strip leading "v" if present
      // e.g. "v1.0.1" → "1.0.1"
      final rawTag = data['tag_name'] as String? ?? '';
      final latestVersion = rawTag.startsWith('v')
          ? rawTag.substring(1)
          : rawTag;

      // Find the APK download URL from release assets
      final assets = data['assets'] as List<dynamic>? ?? [];
      String downloadUrl = '';
      for (final asset in assets) {
        final name = asset['name'] as String? ?? '';
        if (name.endsWith('.apk')) {
          downloadUrl = asset['browser_download_url'] as String? ?? '';
          break;
        }
      }

      // Fallback to HTML release page if no APK asset found
      if (downloadUrl.isEmpty) {
        downloadUrl = data['html_url'] as String? ?? '';
      }

      final releaseNotes = data['body'] as String? ?? 'No release notes.';

      final isUpdateAvailable = _isNewerVersion(
        current: currentVersion,
        latest: latestVersion,
      );

      return UpdateInfo(
        isUpdateAvailable: isUpdateAvailable,
        currentVersion: currentVersion,
        latestVersion: latestVersion,
        downloadUrl: downloadUrl,
        releaseNotes: releaseNotes,
      );
    } catch (_) {
      // Silently fail — update check should never crash the app
      return null;
    }
  }

  /// Downloads the APK from [url], saving it to a temporary directory,
  /// and triggers the Android system installer.
  static Future<void> downloadAndInstallApk({
    required String url,
    required Function(double progress) onProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      // 1. Check/Request storage permission if needed (usually not for temp/cache on modern Android)
      // 2. Check/Request install permission (Android only)
      if (Platform.isAndroid) {
        var status = await Permission.requestInstallPackages.status;
        if (!status.isGranted) {
          status = await Permission.requestInstallPackages.request();
          if (!status.isGranted) {
            throw Exception('Permission to install packages was denied.');
          }
        }
      }

      // 3. Prepare storage path
      final tempDir = await getTemporaryDirectory();
      final filePath = "${tempDir.path}/update.apk";

      // Delete existing file if any
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }

      final dio = Dio();

      // 4. Start download
      await dio.download(
        url,
        filePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            onProgress(received / total);
          }
        },
      );

      // 5. Trigger installation
      final result = await OpenFilex.open(filePath);
      if (result.type != ResultType.done) {
        throw Exception('Failed to open APK: ${result.message}');
      }
    } catch (e) {
      // Log error or rethrow for UI handling
      rethrow;
    }
  }

  static bool _isNewerVersion({
    required String current,
    required String latest,
  }) {
    try {
      // 1. Normalize strings: strip leading 'v' and split by '+' or '-' 
      //    to isolate the semantic part (e.g. "1.2.11-main.38" -> "1.2.11")
      String cleanCurrent = current.startsWith('v') ? current.substring(1) : current;
      String cleanLatest = latest.startsWith('v') ? latest.substring(1) : latest;

      // Extract base version (before + or -)
      final currentBase = cleanCurrent.split(RegExp(r'[+-]'))[0];
      final latestBase = cleanLatest.split(RegExp(r'[+-]'))[0];

      final currentParts = currentBase.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      final latestParts = latestBase.split('.').map((e) => int.tryParse(e) ?? 0).toList();

      while (currentParts.length < 3) {
        currentParts.add(0);
      }
      while (latestParts.length < 3) {
        latestParts.add(0);
      }

      // 2. Compare major.minor.patch
      for (int i = 0; i < 3; i++) {
        if (latestParts[i] > currentParts[i]) return true;
        if (latestParts[i] < currentParts[i]) return false;
      }

      // 3. Compare build numbers/suffixes if base is equal
      // For "1.2.11-main.38", we want to extract "38"
      int currentBuild = _extractBuildNumber(cleanCurrent);
      int latestBuild = _extractBuildNumber(cleanLatest);

      return latestBuild > currentBuild;
    } catch (_) {
      return false;
    }
  }

  static int _extractBuildNumber(String version) {
    try {
      // Look for the last numeric part in the string
      // Matches both "+38" and "-main.38"
      final regExp = RegExp(r'[.+](\d+)$');
      final match = regExp.firstMatch(version);
      if (match != null) {
        return int.tryParse(match.group(1) ?? '0') ?? 0;
      }
    } catch (_) {}
    return 0;
  }
}

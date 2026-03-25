import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

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
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version; // e.g. "1.0.0"

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

  /// Compares semantic versions: "1.0.0" vs "1.0.1"
  /// Returns true if latest is newer than current
  static bool _isNewerVersion({
    required String current,
    required String latest,
  }) {
    try {
      // Strip build numbers for primary version comparison (e.g. "1.0.0+1" -> "1.0.0")
      final currentBase = current.split('+')[0];
      final latestBase = latest.split('+')[0];

      final currentParts = currentBase.split('.').map(int.parse).toList();
      final latestParts = latestBase.split('.').map(int.parse).toList();

      while (currentParts.length < 3) {
        currentParts.add(0);
      }
      while (latestParts.length < 3) {
        latestParts.add(0);
      }

      for (int i = 0; i < 3; i++) {
        if (latestParts[i] > currentParts[i]) return true;
        if (latestParts[i] < currentParts[i]) return false;
      }

      // Compare build numbers if base versions are identical
      final currentBuild = current.contains('+') ? int.tryParse(current.split('+')[1]) ?? 0 : 0;
      final latestBuild = latest.contains('+') ? int.tryParse(latest.split('+')[1]) ?? 0 : 0;

      return latestBuild > currentBuild;
    } catch (_) {
      return false;
    }
  }
}

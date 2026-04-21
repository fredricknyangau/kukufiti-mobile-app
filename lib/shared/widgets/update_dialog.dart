import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:mobile/core/services/update_service.dart';
import 'package:mobile/app/theme/app_theme.dart';

class UpdateDialog extends StatefulWidget {
  final UpdateInfo updateInfo;

  const UpdateDialog({super.key, required this.updateInfo});

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  double _downloadProgress = 0;
  bool _isDownloading = false;
  String? _errorMessage;
  final _cancelToken = CancelToken();

  @override
  void dispose() {
    _cancelToken.cancel();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
      _errorMessage = null;
      _downloadProgress = 0;
    });

    try {
      await UpdateService.downloadAndInstallApk(
        url: widget.updateInfo.downloadUrl,
        onProgress: (progress) {
          if (mounted) {
            setState(() => _downloadProgress = progress);
          }
        },
        cancelToken: _cancelToken,
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _errorMessage = e.toString().contains('denied')
              ? 'Permission denied. Please allow app installation in settings.'
              : 'Download failed. Please check your internet connection.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<CustomColors>();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(
            _isDownloading ? Icons.downloading : Icons.system_update,
            color: theme.primaryColor,
          ),
          const SizedBox(width: 10),
          const Text('Update Available'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Version info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _versionChip(
                  label: 'Current',
                  version: widget.updateInfo.currentVersion,
                  color: customColors?.neutral ?? theme.colorScheme.outline,
                  theme: theme,
                ),
                Icon(Icons.arrow_forward,
                    size: 16, color: customColors?.neutral ?? theme.colorScheme.outline),
                _versionChip(
                  label: 'Latest',
                  version: widget.updateInfo.latestVersion,
                  color: customColors?.success ?? theme.colorScheme.primary,
                  theme: theme,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (!_isDownloading)
            Text(
              widget.updateInfo.releaseNotes.isNotEmpty
                  ? widget.updateInfo.releaseNotes
                  : 'A new version of KukuFiti is available. Update now to get the latest features and fixes.',
              style: const TextStyle(fontSize: 14, height: 1.4),
            )
          else
            Column(
              children: [
                LinearProgressIndicator(
                  value: _downloadProgress,
                  borderRadius: BorderRadius.circular(4),
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
                const SizedBox(height: 8),
                Text(
                  'Downloading update: ${(_downloadProgress * 100).toInt()}%',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                _errorMessage!,
                style: TextStyle(color: theme.colorScheme.error, fontSize: 13),
              ),
            ),
        ],
      ),
      actions: [
        if (!_isDownloading) ...[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Later'),
          ),
          FilledButton.icon(
            onPressed: _handleUpdate,
            icon: const Icon(Icons.download),
            label: const Text('Update Now'),
          ),
        ] else
          TextButton(
            onPressed: () {
              _cancelToken.cancel();
              setState(() => _isDownloading = false);
            },
            child: const Text('Cancel'),
          ),
      ],
    );
  }

  Widget _versionChip({
    required String label,
    required String version,
    required Color color,
    required ThemeData theme,
  }) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
        const SizedBox(height: 2),
        Text(
          'v$version',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

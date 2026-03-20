import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/services/update_service.dart';

class UpdateDialog extends StatelessWidget {
  final UpdateInfo updateInfo;

  const UpdateDialog({super.key, required this.updateInfo});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.system_update, color: Theme.of(context).primaryColor),
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
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _versionChip(
                  label: 'Current',
                  version: updateInfo.currentVersion,
                  color: Colors.grey,
                ),
                const Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
                _versionChip(
                  label: 'Latest',
                  version: updateInfo.latestVersion,
                  color: Colors.green,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'A new version of KukuFiti is available. '
            'Update now to get the latest features and fixes.',
            style: TextStyle(fontSize: 14, height: 1.4),
          ),
        ],
      ),
      actions: [
        // Dismiss — user can update later
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Later'),
        ),
        // Update now — opens download link
        FilledButton.icon(
          onPressed: () async {
            Navigator.of(context).pop();
            final uri = Uri.parse(updateInfo.downloadUrl);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
          icon: const Icon(Icons.download),
          label: const Text('Update Now'),
        ),
      ],
    );
  }

  Widget _versionChip({
    required String label,
    required String version,
    required Color color,
  }) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
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

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
    final size = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: size.width > 400 ? 400 : double.infinity,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with Gradient and Icon
            _buildHeader(theme),
            
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upgrade KukuFiti',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Version Comparison Pill
                  _buildVersionComparison(theme, customColors),
                  
                  const SizedBox(height: 20),
                  
                  // Release Notes or Content
                  _buildContent(theme),
                  
                  if (_errorMessage != null)
                    _buildError(theme),
                    
                  const SizedBox(height: 24),
                  
                  // Progress or Actions
                  if (_isDownloading)
                    _buildProgress(theme)
                  else
                    _buildActions(context, theme),
                ],
              ),
            ),
          ],
        ),
      ).animate().scale(
            duration: 300.ms,
            curve: Curves.easeOutBack,
            begin: const Offset(0.8, 0.8),
          ).fadeIn(),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.7),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Subtle background pattern
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              LucideIcons.rocket,
              size: 140,
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          Center(
            child: const Icon(
              LucideIcons.rocket,
              color: Colors.white,
              size: 48,
            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
             .moveY(begin: -5, end: 5, duration: 2.seconds, curve: Curves.easeInOut),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionComparison(ThemeData theme, CustomColors? customColors) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _versionInfo(
            label: 'CURRENT',
            version: widget.updateInfo.currentVersion,
            color: theme.colorScheme.onSurfaceVariant,
            theme: theme,
          ),
          Icon(LucideIcons.arrowRight, size: 20, color: theme.colorScheme.primary.withValues(alpha: 0.5)),
          _versionInfo(
            label: 'LATEST',
            version: widget.updateInfo.latestVersion,
            color: customColors?.success ?? theme.colorScheme.primary,
            theme: theme,
            isNew: true,
          ),
        ],
      ),
    );
  }

  Widget _versionInfo({
    required String label,
    required String version,
    required Color color,
    required ThemeData theme,
    bool isNew = false,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            letterSpacing: 1.2,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'v$version',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildContent(ThemeData theme) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 150),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What\'s New',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.updateInfo.releaseNotes.isNotEmpty
                  ? widget.updateInfo.releaseNotes
                  : 'We\'ve added new features and improved performance to make your poultry management smoother.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(LucideIcons.alertCircle, size: 18, color: theme.colorScheme.error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _errorMessage!,
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgress(ThemeData theme) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              height: 12,
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            AnimatedContainer(
              duration: 300.ms,
              height: 12,
              width: (MediaQuery.of(context).size.width - 96) * _downloadProgress,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.colorScheme.primary, theme.colorScheme.primary.withValues(alpha: 0.7)],
                ),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Downloading...',
              style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              '${(_downloadProgress * 100).toInt()}%',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: () {
            _cancelToken.cancel();
            setState(() => _isDownloading = false);
          },
          child: Text('Cancel Download', style: TextStyle(color: theme.colorScheme.error)),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Maybe Later',
              style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _handleUpdate,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ).copyWith(
              elevation: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.pressed) ? 0 : 4),
            ),
            child: const Text('Update Now', style: TextStyle(fontWeight: FontWeight.bold)),
          ).animate(onPlay: (controller) => controller.repeat())
           .shimmer(delay: 3.seconds, duration: 1500.ms, color: Colors.white.withValues(alpha: 0.3)),
        ),
      ],
    );
  }
}

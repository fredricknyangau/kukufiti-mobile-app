import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:dio/dio.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/api_endpoints.dart';
import 'package:mobile/shared/widgets/custom_card.dart';
import 'package:mobile/app/theme/app_theme.dart';

class VoiceObservationScreen extends ConsumerStatefulWidget {
  const VoiceObservationScreen({super.key});

  @override
  ConsumerState<VoiceObservationScreen> createState() => _VoiceObservationScreenState();
}

class _VoiceObservationScreenState extends ConsumerState<VoiceObservationScreen> {
  final _record = AudioRecorder();
  bool _isRecording = false;
  bool _isProcessing = false;
  Map<String, dynamic>? _result;

  @override
  void dispose() {
    _record.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (await _record.hasPermission()) {
        final dir = await getTemporaryDirectory();
        final path = p.join(dir.path, 'observation_${DateTime.now().millisecondsSinceEpoch}.m4a');
        
        const config = RecordConfig();
        await _record.start(config, path: path);
        
        setState(() {
          _isRecording = true;
          _result = null;
        });
        HapticFeedback.heavyImpact();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _stopRecording() async {
    final path = await _record.stop();
    setState(() {
      _isRecording = false;
    });
    HapticFeedback.mediumImpact();
    if (path != null) {
      _processAudio(path);
    }
  }

  Future<void> _processAudio(String path) async {
    setState(() => _isProcessing = true);
    
    try {
      final file = await MultipartFile.fromFile(path, filename: 'record.m4a');
      final formData = FormData.fromMap({'file': file});
      
      final response = await ApiClient.instance.post(
        ApiEndpoints.aiVoiceRecord,
        data: formData,
      );
      
      setState(() {
        _result = response.data;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() => _isProcessing = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Processing failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Voice Observation')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Spacer(),
            if (_isProcessing)
              const CircularProgressIndicator()
            else if (_result != null)
              _buildResultView(theme)
            else
              _buildRecordingView(theme),
            const Spacer(),
            if (!_isProcessing)
              _buildMicrophoneButton(theme),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingView(ThemeData theme) {
    return Column(
      children: [
        _isRecording 
          ? Icon(
              LucideIcons.mic,
              size: 80,
              color: theme.colorScheme.primary,
            ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1200.ms)
          : Icon(
              LucideIcons.micOff,
              size: 80,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
        const SizedBox(height: 24),
        Text(
          _isRecording ? 'Listening...' : 'Tap to Record Observation',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'e.g. "I found 2 dead birds in flock A today. They looked lethargic."',
          textAlign: TextAlign.center,
          style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
        ),
      ],
    );
  }

  Widget _buildResultView(ThemeData theme) {
    final transcript = _result?['transcript'] ?? '';
    final mortality = _result?['mortality_count'];
    final obs = List<String>.from(_result?['observations'] ?? []);
    final entities = List<String>.from(_result?['detected_entities'] ?? []);
    final suggestion = _result?['suggested_action'] ?? '';
    final customColors = theme.extension<CustomColors>();

    return ListView(
      shrinkWrap: true,
      children: [
        CustomCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TRANSCRIPT', 
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text('"$transcript"', style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 15)),
              const Divider(height: 32),
              if (mortality != null) ...[
                _buildResItem(LucideIcons.skull, 'Mortality Detected', '$mortality birds', theme.colorScheme.error),
              ],
              if (obs.isNotEmpty) ...[
                  _buildResItem(LucideIcons.eye, 'Observations', obs.join(', '), customColors?.warning ?? Colors.orange),
              ],
              if (entities.isNotEmpty) ...[
                  _buildResItem(LucideIcons.package, 'Entities', entities.join(', '), customColors?.info ?? Colors.blue),
              ],
              const Divider(height: 32),
              Text(
                'AI SUGGESTION', 
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(suggestion, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () => setState(() => _result = null),
          icon: const Icon(LucideIcons.mic, size: 18),
          label: const Text('Record Another'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ],
    );
  }

  Widget _buildResItem(IconData icon, String label, String val, Color color) {
     return Padding(
       padding: const EdgeInsets.symmetric(vertical: 6.0),
       child: Row(
         children: [
           Container(
             padding: const EdgeInsets.all(4),
             decoration: BoxDecoration(
               color: color.withValues(alpha: 0.1),
               shape: BoxShape.circle,
             ),
             child: Icon(icon, size: 14, color: color),
           ),
           const SizedBox(width: 12),
           Text('$label: ', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
           Expanded(child: Text(val, style: const TextStyle(fontSize: 13))),
         ],
       ),
     );
  }

  Widget _buildMicrophoneButton(ThemeData theme) {
    final activeColor = theme.colorScheme.error;
    final inactiveColor = theme.colorScheme.primary;
    
    return GestureDetector(
      onLongPress: _startRecording,
      onLongPressUp: _stopRecording,
      onTap: _isRecording ? _stopRecording : _startRecording,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: _isRecording ? activeColor : inactiveColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (_isRecording ? activeColor : inactiveColor).withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 5,
            )
          ],
        ),
        child: Icon(
          _isRecording ? LucideIcons.square : LucideIcons.mic,
          color: Colors.white,
          size: 40,
        ),
      ),
    ).animate(target: _isRecording ? 1 : 0).scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1));
  }
}

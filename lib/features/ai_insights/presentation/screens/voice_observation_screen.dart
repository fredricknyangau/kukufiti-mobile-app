import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../presentation/widgets/custom_card.dart';

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
        Icon(
          _isRecording ? LucideIcons.mic : LucideIcons.micOff,
          size: 80,
          color: _isRecording ? theme.colorScheme.primary : Colors.grey,
        ).animate(onPlay: (c) => c.repeat()).shimmer(enabled: _isRecording),
        const SizedBox(height: 24),
        Text(
          _isRecording ? 'Listening...' : 'Tap to Record Observation',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        const Text(
          'e.g. "I found 2 dead birds in flock A today. They looked lethargic."',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
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

    return ListView(
      shrinkWrap: true,
      children: [
        CustomCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Transcript', style: theme.textTheme.labelSmall),
              const SizedBox(height: 4),
              Text('"$transcript"', style: const TextStyle(fontStyle: FontStyle.italic)),
              const Divider(height: 24),
              if (mortality != null) ...[
                _buildResItem(LucideIcons.skull, 'Mortality Detected', '$mortality birds', Colors.red),
              ],
              if (obs.isNotEmpty) ...[
                  _buildResItem(LucideIcons.eye, 'Observations', obs.join(', '), Colors.orange),
              ],
              if (entities.isNotEmpty) ...[
                  _buildResItem(LucideIcons.package, 'Entities', entities.join(', '), Colors.blue),
              ],
              const Divider(height: 24),
              Text('AI Suggestion', style: theme.textTheme.labelSmall),
              const SizedBox(height: 4),
              Text(suggestion, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => setState(() => _result = null),
          child: const Text('Record Another'),
        ),
      ],
    );
  }

  Widget _buildResItem(IconData icon, String label, String val, Color color) {
     return Padding(
       padding: const EdgeInsets.symmetric(vertical: 4.0),
       child: Row(
         children: [
           Icon(icon, size: 16, color: color),
           const SizedBox(width: 8),
           Text('$label: ', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
           Expanded(child: Text(val, style: const TextStyle(fontSize: 12))),
         ],
       ),
     );
  }

  Widget _buildMicrophoneButton(ThemeData theme) {
    return GestureDetector(
      onLongPress: _startRecording,
      onLongPressUp: _stopRecording,
      onTap: _isRecording ? _stopRecording : _startRecording,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: _isRecording ? Colors.red : theme.colorScheme.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (_isRecording ? Colors.red : theme.colorScheme.primary).withValues(alpha: 0.3),
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
    );
  }
}

// Add extension for animation if not imported
extension AnimateExtension on Widget {
   Widget animate({Function(dynamic)? onPlay}) => this; // Placeholder for actual flutter_animate if used
   Widget shimmer({bool enabled = false}) => this; // Placeholder
}

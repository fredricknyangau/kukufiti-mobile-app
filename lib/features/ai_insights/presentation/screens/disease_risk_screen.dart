import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../data/models/disease_risk.dart';
import '../providers/ai_insights_provider.dart';

class DiseaseRiskScreen extends ConsumerStatefulWidget {
  const DiseaseRiskScreen({super.key});

  @override
  ConsumerState<DiseaseRiskScreen> createState() => _DiseaseRiskScreenState();
}

class _DiseaseRiskScreenState extends ConsumerState<DiseaseRiskScreen> {
  final _symptomsController = TextEditingController();
  final _vaccinesController = TextEditingController();
  String _mortalityAlert = 'NORMAL';
  File? _imageFile;
  String? _imageBase64;
  final _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        final bytes = await File(pickedFile.path).readAsBytes();
        setState(() {
          _imageFile = File(pickedFile.path);
          _imageBase64 = base64Encode(bytes);
        });
      }
    } catch (e) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
      }
    }
  }

  @override
  void dispose() {
    _symptomsController.dispose();
    _vaccinesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final aiState = ref.watch(aiInsightsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Disease Risk')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Analyze Outbreak Risks',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Identify symptoms and provide recent vaccine records. Our AI will contrast standard schedule thresholds.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            TextFormField(
              controller: _symptomsController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Observed Symptoms',
                hintText: 'e.g., coughing, lethargy, wet droppings',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.sick),
              ),
              onChanged: (val) => setState(() {}),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _vaccinesController,
              decoration: const InputDecoration(
                labelText: 'Recent Vaccinations',
                hintText: 'e.g., Gumboro, Newcastle',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.vaccines),
              ),
              onChanged: (val) => setState(() {}),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: _mortalityAlert,
              decoration: const InputDecoration(
                labelText: 'Mortality Level Alert',
                border: OutlineInputBorder(),
              ),
              items: ['NORMAL', 'WARNING', 'CRITICAL']
                  .map((val) => DropdownMenuItem(value: val, child: Text(val)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _mortalityAlert = val);
              },
            ),
            const SizedBox(height: 24),

            const Text('Upload Diagnostic Photo (Droppings/Eyes)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            if (_imageFile != null) ...[
              const SizedBox(height: 12),
              Stack(
                alignment: Alignment.topRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(_imageFile!, height: 180, width: double.infinity, fit: BoxFit.cover),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.white, size: 28),
                    onPressed: () => setState(() {
                      _imageFile = null;
                      _imageBase64 = null;
                    }),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: (_symptomsController.text.isEmpty && _imageBase64 == null || aiState.isLoading)
                  ? null
                  : _triggerAnalysis,
              child: aiState.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Detect Risks'),
            ),

            const SizedBox(height: 32),

            if (aiState.error != null) ...[
              Text(aiState.error!, style: const TextStyle(color: Colors.red)),
            ],

            if (aiState.diseaseRisk != null) ...[
              _buildReportCard(theme, aiState.diseaseRisk!),
            ],
          ],
        ),
      ),
    );
  }

  void _triggerAnalysis() {
    HapticFeedback.vibrate();
    
    final symptomsList = _symptomsController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final vaccinesList = _vaccinesController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final request = DiseaseRiskRequest(
      symptoms: symptomsList,
      recentVaccinations: vaccinesList,
      mortalityAlertLevel: _mortalityAlert,
      imageBase64: _imageBase64,
    );

    ref.read(aiInsightsProvider.notifier).fetchDiseaseRisk(request);
  }

  Widget _buildReportCard(ThemeData theme, DiseaseRiskResponse response) {
    Color riskColor = Colors.green;
    if (response.riskLevel == 'HIGH') riskColor = Colors.red;
    if (response.riskLevel == 'MEDIUM') riskColor = Colors.orange;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(
               'Risk Level: ${response.riskLevel}',
               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: riskColor),
             ),
             const SizedBox(height: 16),
             
             if (response.suspectedConditions.isNotEmpty) ...[
                const Text('Suspected Conditions:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...response.suspectedConditions.map((c) => Text('• $c')),
                const SizedBox(height: 12),
             ],

             if (response.missedCriticalVaccines.isNotEmpty) ...[
                const Text('Possible Missed Vaccines:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                ...response.missedCriticalVaccines.map((v) => Text('• $v')),
                const SizedBox(height: 12),
             ],

             const Divider(),
             const Text('Recommendations:', style: TextStyle(fontWeight: FontWeight.bold)),
             ...response.recommendations.map((r) => Text('• $r')),
          ],
        ),
      ),
    );
  }
}

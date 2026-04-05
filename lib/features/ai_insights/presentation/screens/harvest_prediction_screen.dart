import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/harvest_prediction.dart';
import '../providers/ai_insights_provider.dart';
import '../../../../providers/broiler_provider.dart';

class HarvestPredictionScreen extends ConsumerStatefulWidget {
  const HarvestPredictionScreen({super.key});

  @override
  ConsumerState<HarvestPredictionScreen> createState() => _HarvestPredictionScreenState();
}

class _HarvestPredictionScreenState extends ConsumerState<HarvestPredictionScreen> {
  String? _selectedBatchId;
  final _targetWeightController = TextEditingController();

  @override
  void dispose() {
    _targetWeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final broilerState = ref.watch(broilerProvider);
    final aiState = ref.watch(aiInsightsProvider);
    final batches = broilerState.batches;

    return Scaffold(
      appBar: AppBar(title: const Text('Harvest Readiness')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Predict Optimal Harvest Date',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Select a batch and entered your desired target weights to compute estimated finishing days.',
              style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 24),

            DropdownButtonFormField<String>(
              initialValue: _selectedBatchId,
              decoration: const InputDecoration(
                labelText: 'Select Batch',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.layers),
              ),
              items: batches.map((batch) {
                return DropdownMenuItem<String>(
                  value: batch.id,
                  child: Text(batch.name),
                );
              }).toList(),
              onChanged: (val) {
                setState(() => _selectedBatchId = val);
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _targetWeightController,
              decoration: const InputDecoration(
                labelText: 'Target Weight (kg)',
                hintText: 'e.g., 2.2',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.fitness_center),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (val) => setState(() {}),
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: (_selectedBatchId == null || _targetWeightController.text.isEmpty || aiState.isLoading)
                  ? null
                  : _triggerAnalysis,
              child: aiState.isLoading
                  ? CircularProgressIndicator(color: theme.colorScheme.onPrimary)
                  : const Text('Predict Readiness'),
            ),

            const SizedBox(height: 32),

            if (aiState.error != null) ...[
              Text(aiState.error!, style: TextStyle(color: theme.colorScheme.error)),
            ],

            if (aiState.harvestPrediction != null) ...[
              _buildReportCard(theme, aiState.harvestPrediction!),
            ],
          ],
        ),
      ),
    );
  }

  void _triggerAnalysis() {
    HapticFeedback.heavyImpact();
    final batches = ref.read(broilerProvider).batches;
    final batch = batches.firstWhere((b) => b.id == _selectedBatchId);

    // Calculate age
    final ageDays = DateTime.now().difference(batch.commencementDate).inDays;

    final request = HarvestPredictionRequest(
      flockAgeDays: ageDays,
      currentAvgWeightKg: 1.5, // Fallback
      targetWeightKg: double.parse(_targetWeightController.text),
      breed: batch.breed ?? 'Unknown',
    );

    ref.read(aiInsightsProvider.notifier).fetchHarvestPrediction(request);
  }

  Widget _buildReportCard(ThemeData theme, HarvestPredictionResponse response) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(
               'Status: ${response.statusFlag}',
               style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
             ),
             const SizedBox(height: 12),
             Text('Estimated Days remaining: ${response.estimatedDaysToTarget} days'),
             Text('Daily gain estimate: ${response.dailyGainEstimateG.toStringAsFixed(1)}g'),
             const Divider(height: 24),
             const Text('Recommendations:', style: TextStyle(fontWeight: FontWeight.bold)),
             ...response.recommendations.map((r) => Text('• $r')),
          ],
        ),
      ),
    );
  }
}

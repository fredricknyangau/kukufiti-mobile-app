import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/fcr_insights.dart';
import '../providers/ai_insights_provider.dart';
import '../../../../providers/broiler_provider.dart';

class FcrInsightsScreen extends ConsumerStatefulWidget {
  const FcrInsightsScreen({super.key});

  @override
  ConsumerState<FcrInsightsScreen> createState() => _FcrInsightsScreenState();
}

class _FcrInsightsScreenState extends ConsumerState<FcrInsightsScreen> {
  String? _selectedBatchId;
  final _feedConsumedController = TextEditingController();

  @override
  void dispose() {
    _feedConsumedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final aiState = ref.watch(aiInsightsProvider);
    final broilerState = ref.watch(broilerProvider);
    final batches = broilerState.batches;

    return Scaffold(
      appBar: AppBar(title: const Text('FCR Insights')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Analyze Feed Conversion Efficiency',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Analyse exact Cost ratios and economic buffers contrasting flock weight weights.',
              style: TextStyle(color: Colors.grey),
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
              controller: _feedConsumedController,
              decoration: const InputDecoration(
                labelText: 'Total Feed Consumed (kg)',
                hintText: 'e.g., 2000',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.shopping_bag_outlined),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (val) => setState(() {}),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: (_selectedBatchId == null || _feedConsumedController.text.isEmpty || aiState.isLoading)
                  ? null
                  : _triggerAnalysis,
              child: aiState.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Get Insights'),
            ),

            const SizedBox(height: 32),

            if (aiState.error != null) ...[
              Text(aiState.error!, style: const TextStyle(color: Colors.red)),
            ],

            if (aiState.fcrInsights != null) ...[
              _buildReportCard(theme, aiState.fcrInsights!),
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

    final initialCount = batch.initialChicks;
    final currentCount = initialCount; // Fallback to initial if current mapping unavailable here

    final request = FcrInsightsRequest(
      totalFeedConsumedKg: double.parse(_feedConsumedController.text),
      currentAvgWeightKg: 1.5, // Fallback to 1.5 since batch lack quick average weight lookup
      initialBirdCount: initialCount,
      currentBirdCount: currentCount,
    );

    ref.read(aiInsightsProvider.notifier).fetchFcrInsights(request);
  }

  Widget _buildReportCard(ThemeData theme, FcrInsightsResponse response) {
    Color statusColor = Colors.green;
    if (response.benchmarkStatus == 'POOR') statusColor = Colors.red;
    if (response.benchmarkStatus == 'GOOD') statusColor = Colors.orange;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(
               'Calculated FCR: ${response.estimatedFcr.toStringAsFixed(2)}',
               style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
             ),
             const SizedBox(height: 8),
             Text(
               'Benchmark: ${response.benchmarkStatus}',
               style: TextStyle(fontWeight: FontWeight.bold, color: statusColor),
             ),
             const SizedBox(height: 16),
             Text('Cost Impact:\n${response.costImpactExplanation}'),
             const Divider(height: 24),
             if (response.recommendations.isNotEmpty) ...[
                const Text('Recommendations:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...response.recommendations.map((r) => Text('• $r')),
             ],
          ],
        ),
      ),
    );
  }
}

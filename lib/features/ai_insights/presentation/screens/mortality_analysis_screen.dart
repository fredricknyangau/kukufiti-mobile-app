import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/mortality_analysis.dart';
import '../providers/ai_insights_provider.dart';
import '../../../../providers/broiler_provider.dart';
import '../../../../providers/data_providers.dart' as data_providers;

class MortalityAdvisoryScreen extends ConsumerStatefulWidget {
  const MortalityAdvisoryScreen({super.key});

  @override
  ConsumerState<MortalityAdvisoryScreen> createState() => _MortalityAdvisoryScreenState();
}

class _MortalityAdvisoryScreenState extends ConsumerState<MortalityAdvisoryScreen> {
  String? _selectedBatchId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final broilerState = ref.watch(broilerProvider);
    final aiState = ref.watch(aiInsightsProvider);
    final mortalityAsync = ref.watch(data_providers.mortalityProvider);

    final batches = broilerState.batches;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mortality Analytics'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Analyze Mortality Patterns',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select a batch below. Our AI will pull the daily mortality records you logged and detect anomalies, risk trends or potential disease outbreaks.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Batch dropdown selection
            DropdownButtonFormField<String>(
              initialValue: _selectedBatchId,
              decoration: const InputDecoration(
                labelText: 'Select Batch',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.layers),
              ),
              items: batches.map((batch) {
                return DropdownMenuItem<String>(
                  value: batch['id'].toString(),
                  child: Text(batch['name'] ?? 'Batch #${batch['id']}'),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedBatchId = val);
                }
              },
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: (_selectedBatchId == null || aiState.isLoading) 
                  ? null 
                  : () => _triggerAnalysis(batches, mortalityAsync.value ?? []),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: aiState.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Analyze Trends', style: TextStyle(fontSize: 16)),
            ),

            const SizedBox(height: 32),

            if (aiState.error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(aiState.error!, style: TextStyle(color: Colors.red.shade900)),
              ),
            ],

            if (aiState.mortalityAnalysis != null) ...[
              _buildReportCard(theme, aiState.mortalityAnalysis!),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _triggerAnalysis(List<dynamic> batches, List<dynamic> mortalityLogs) async {
    final batch = batches.firstWhere((b) => b['id'].toString() == _selectedBatchId);
    final initialCount = batch['initial_count'] ?? batch['batch_size'] ?? 0;
    final currentCount = batch['current_count'] ?? initialCount;

    // Filter relevant logs for the selected batch
    final filteredLogs = mortalityLogs
        .where((m) => m['flock_id'].toString() == _selectedBatchId)
        .map((m) => MortalityLogEntry(
              date: m['date'] ?? '',
              count: m['count'] ?? 0,
              cause: m['cause'],
            ))
        .toList();

    final request = MortalityAnalysisRequest(
      flockId: _selectedBatchId,
      breed: batch['breed'] ?? 'Cobb 500',
      initialBirdCount: initialCount,
      currentBirdCount: currentCount,
      recentMortality: filteredLogs,
    );

    ref.read(aiInsightsProvider.notifier).fetchMortalityAnalysis(request);
  }

  Widget _buildReportCard(ThemeData theme, MortalityAnalysisResponse response) {
    Color alertColor;
    IconData alertIcon;
    switch (response.alertLevel) {
      case 'CRITICAL':
        alertColor = Colors.red;
        alertIcon = Icons.error_outline;
        break;
      case 'WARNING':
        alertColor = Colors.orange;
        alertIcon = Icons.warning_amber_outlined;
        break;
      default:
        alertColor = Colors.green;
        alertIcon = Icons.check_circle_outline;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(alertIcon, color: alertColor, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${response.alertLevel} Alert',
                        style: TextStyle(color: alertColor, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Cumulative rate: ${response.cumulativeMortalityRate.toStringAsFixed(2)}%',
                        style: TextStyle(color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            
            if (response.potentialCauses.isNotEmpty) ...[
              const Text('Potential Triggers:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...response.potentialCauses.map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.arrow_right_rounded, size: 20, color: Colors.grey),
                        Expanded(child: Text(p)),
                      ],
                    ),
                  )),
              const SizedBox(height: 16),
            ],

            if (response.recommendations.isNotEmpty) ...[
              const Text('Action Recommendations:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...response.recommendations.map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lightbulb_outline, size: 18, color: Colors.orange),
                        const SizedBox(width: 6),
                        Expanded(child: Text(p)),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/feed_recommendation.dart';
import '../providers/ai_insights_provider.dart';
import '../../../../core/theme/app_theme.dart';

class FeedAdvisoryScreen extends ConsumerStatefulWidget {
  const FeedAdvisoryScreen({super.key});

  @override
  ConsumerState<FeedAdvisoryScreen> createState() => _FeedAdvisoryScreenState();
}

class _FeedAdvisoryScreenState extends ConsumerState<FeedAdvisoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _countController = TextEditingController();
  String _selectedBreed = 'Cobb 500';

  final List<String> _breeds = ['Cobb 500', 'Ross 308', 'Hubbard', 'Arbor Acres'];

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    _countController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final request = FeedRecommendationRequest(
        flockAgeDays: int.parse(_ageController.text),
        currentAvgWeightKg: double.parse(_weightController.text),
        breed: _selectedBreed,
        birdCount: int.parse(_countController.text),
      );
      ref.read(aiInsightsProvider.notifier).fetchFeedRecommendation(request);
    }
  }

  @override
  Widget build(BuildContext context) {
    final aiState = ref.watch(aiInsightsProvider);
    final theme = Theme.of(context);
    final customColors = theme.extension<CustomColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Feed Advisory'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Get Smart Feed Recommendations',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your flock details below and our AI engine will calculate the optimal daily feed allocation based on standard growth curves.',
              style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _ageController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Flock Age (Days)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.date_range),
                          ),
                          validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _weightController,
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Avg Weight (Kg)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.monitor_weight),
                          ),
                          validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedBreed,
                          decoration: const InputDecoration(
                            labelText: 'Breed',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.pets),
                          ),
                          items: _breeds.map((breed) {
                            return DropdownMenuItem(
                              value: breed,
                              child: Text(breed),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedBreed = val);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _countController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Active Birds',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.numbers),
                          ),
                          validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: aiState.isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: aiState.isLoading
                        ? CircularProgressIndicator(color: theme.colorScheme.onPrimary)
                        : const Text('Calculate Recommendation', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            if (aiState.error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.colorScheme.error.withValues(alpha: 0.3)),
                ),
                child: Text(
                  aiState.error!,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            ],
            if (aiState.recommendation != null) ...[
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'AI Advisory Report',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Daily Feed Required:', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                          Text(
                            '${aiState.recommendation!.recommendedDailyKg.toStringAsFixed(2)} Kg',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Growth Sub-Status:', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                          Chip(
                            label: Text(
                              aiState.recommendation!.statusFlag,
                              style: TextStyle(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold),
                            ),
                            backgroundColor: aiState.recommendation!.statusFlag == 'NORMAL' 
                                ? customColors.success 
                                : aiState.recommendation!.statusFlag == 'LOW' 
                                  ? customColors.warning 
                                  : theme.colorScheme.error,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text('Insights & Reasoning:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                        aiState.recommendation!.reasoningExplanation,
                        style: const TextStyle(height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

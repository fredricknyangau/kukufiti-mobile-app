import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../presentation/widgets/custom_card.dart';
import '../../../../providers/data_providers.dart';
import '../../../../providers/broiler_provider.dart';
import '../../../../core/models/broiler_models.dart';
import '../../../../core/theme/app_theme.dart';

class HarvestOptimizationScreen extends ConsumerStatefulWidget {
  const HarvestOptimizationScreen({super.key});

  @override
  ConsumerState<HarvestOptimizationScreen> createState() => _HarvestOptimizationScreenState();
}

class _HarvestOptimizationScreenState extends ConsumerState<HarvestOptimizationScreen> {
  final _feedCostController = TextEditingController(text: '75');
  final _birdPriceController = TextEditingController(text: '450');
  String? _selectedFlockId;
  bool _isProcessing = false;
  Map<String, dynamic>? _result;

  @override
  void dispose() {
    _feedCostController.dispose();
    _birdPriceController.dispose();
    super.dispose();
  }

  Future<void> _runOptimization() async {
    if (_selectedFlockId == null) return;
    
    setState(() => _isProcessing = true);
    HapticFeedback.selectionClick();

    try {
      // Find the selected flock to get current metrics
      final broilerState = ref.read(broilerProvider);
      final flocks = broilerState.batches;
      final flock = flocks.firstWhere((f) => f.id == _selectedFlockId);
      final weightData = ref.read(weightProvider).value ?? [];
      final latestWeight = weightData.isNotEmpty ? weightData.last.averageWeight / 1000 : 1.8;

      final payload = {
        'flock_id': _selectedFlockId,
        'current_avg_weight_kg': latestWeight,
        'feed_cost_per_kg': double.parse(_feedCostController.text),
        'expected_sale_price_per_kg': double.parse(_birdPriceController.text),
        'current_age_days': DateTime.now().difference(flock.commencementDate).inDays,
        'breed': flock.breed,
      };

      final response = await ApiClient.instance.post(
        ApiEndpoints.aiHarvestOptimization,
        data: payload,
      );

      setState(() {
        _result = response.data;
        _isProcessing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Optimization failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final broilerState = ref.watch(broilerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profit Optimizer')),
      body: broilerState.isLoading && broilerState.batches.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('Maximize your Harvest ROI', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('AI analyzes growth curves and market prices to find your most profitable sell date.', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
            const SizedBox(height: 32),
            
            _buildInputSection(theme, broilerState.batches),
            
            const SizedBox(height: 32),
            if (_isProcessing)
              const Center(child: CircularProgressIndicator())
            else if (_result != null)
              _buildResultSection(theme)
            else
              ElevatedButton.icon(
                onPressed: _selectedFlockId == null ? null : _runOptimization,
                icon: const Icon(LucideIcons.zap),
                label: const Text('Run Profit Analysis'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              ),
          ],
        ),
    );
  }

  Widget _buildInputSection(ThemeData theme, List<Batch> flocks) {
    return CustomCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Input Parameters', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            initialValue: _selectedFlockId,
            decoration: const InputDecoration(labelText: 'Select Flock', border: OutlineInputBorder()),
            items: flocks.map((f) => DropdownMenuItem<String>(value: f.id, child: Text(f.name))).toList(),
            onChanged: (val) => setState(() => _selectedFlockId = val),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _feedCostController,
                  decoration: const InputDecoration(labelText: 'Feed Cost (KES/kg)', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _birdPriceController,
                  decoration: const InputDecoration(labelText: 'Bird Price (KES)', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultSection(ThemeData theme) {
    final optimalAge = _result?['optimal_harvest_age_days'];
    final projectedProfit = _result?['projected_profit_at_optimal'];
    final reason = _result?['reasoning'];
    final risks = List<String>.from(_result?['risk_factors'] ?? []);
    final trend = List<Map<String, dynamic>>.from(_result?['daily_profit_trend'] ?? []);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomCard(
          isPremium: true,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text('OPTIMAL HARVEST DATE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.extension<CustomColors>()?.success ?? Colors.green)),
              const SizedBox(height: 8),
              Text('Day $optimalAge', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: -2)),
              Text('Estimated Profit: KES $projectedProfit', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text('Why this date?', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(reason ?? ''),
        const SizedBox(height: 24),
        Text('Profit Trend (Next 7 Days)', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        SizedBox(
          height: 150,
          child: _buildTrendChart(theme, trend),
        ),
        const SizedBox(height: 24),
        if (risks.isNotEmpty) ...[
          Text('Risk Factors', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...risks.map((r) => Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Row(children: [Icon(LucideIcons.alertCircle, size: 14, color: theme.extension<CustomColors>()?.warning ?? Colors.orange), const SizedBox(width: 8), Expanded(child: Text(r, style: const TextStyle(fontSize: 13)))]),
          )),
        ],
        const SizedBox(height: 32),
        OutlinedButton(
          onPressed: () => setState(() => _result = null),
          child: const Center(child: Text('Recalculate')),
        ),
      ],
    );
  }

  Widget _buildTrendChart(ThemeData theme, List<Map<String, dynamic>> trend) {
    if (trend.isEmpty) return const Center(child: Text('No trend data'));
    
    final spots = <FlSpot>[];
    for (int i = 0; i < trend.length; i++) {
      spots.add(FlSpot(i.toDouble(), (trend[i]['profit'] as num).toDouble()));
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: theme.extension<CustomColors>()?.success ?? Colors.green,
            barWidth: 4,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(show: true, color: (theme.extension<CustomColors>()?.success ?? Colors.green).withValues(alpha: 0.1)),
          ),
        ],
      ),
    );
  }
}

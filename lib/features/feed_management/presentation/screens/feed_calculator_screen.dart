import 'package:flutter/material.dart';
import 'package:mobile/core/constants/broiler_constants.dart';
import 'package:mobile/shared/widgets/custom_card.dart';

class FeedCalculatorScreen extends StatefulWidget {
  const FeedCalculatorScreen({super.key});

  @override
  State<FeedCalculatorScreen> createState() => _FeedCalculatorScreenState();
}

class _FeedCalculatorScreenState extends State<FeedCalculatorScreen> {
  String _selectedTarget = 'starter';
  final Map<String, double> _quantities = {};

  @override
  void initState() {
    super.initState();
    // Initialize quantities to 0
    for (var ing in localFeedIngredients) {
      _quantities[ing.name] = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final target = feedRequirements[_selectedTarget] ?? {'protein': 0.0, 'energy': 0.0};

    // Calculate totals
    double totalWeight = 0;
    double totalProteinGrams = 0;
    double totalEnergyKcal = 0;

    for (var ing in localFeedIngredients) {
      final qty = _quantities[ing.name] ?? 0;
      if (qty > 0) {
        totalWeight += qty;
        totalProteinGrams += (qty * (ing.proteinContent ?? 0.0) / 100);
        totalEnergyKcal += (qty * (ing.energyContent ?? 0.0));
      }
    }

    final double currentProteinPercent = totalWeight > 0 ? (totalProteinGrams / totalWeight) * 100 : 0;
    final double currentEnergy = totalWeight > 0 ? (totalEnergyKcal / totalWeight) : 0;

    // Compare against targets
    final targetProtein = target['protein'] ?? 0.0;
    final targetEnergy = target['energy'] ?? 0.0;

    final bool proteinMatch = currentProteinPercent >= targetProtein - 1 && currentProteinPercent <= targetProtein + 1;
    final bool energyMatch = currentEnergy >= targetEnergy - 100 && currentEnergy <= targetEnergy + 100;

    return Scaffold(
      appBar: AppBar(title: const Text('Feed Formulation')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedTarget,
              decoration: const InputDecoration(
                labelText: 'Target Ration Type',
                border: OutlineInputBorder(),
              ),
              items: ['starter', 'grower', 'finisher']
                  .map((val) => DropdownMenuItem(
                      value: val, child: Text(val.toUpperCase())))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedTarget = val);
              },
            ),
            const SizedBox(height: 24),

            _buildSummaryCard(currentProteinPercent, targetProtein, currentEnergy, targetEnergy, totalWeight, proteinMatch, energyMatch),
            
            const SizedBox(height: 24),
            Text('Ingredients (kg)', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            ...localFeedIngredients.map((ing) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CustomCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(ing.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text('CP: ${ing.proteinContent}% | ME: ${ing.energyContent} kcal/kg', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          initialValue: _quantities[ing.name]?.toString() == '0.0' ? '' : _quantities[ing.name]?.toString(),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            hintText: '0',
                            isDense: true,
                            suffixText: 'kg',
                          ),
                          onChanged: (val) {
                            setState(() {
                              _quantities[ing.name] = double.tryParse(val) ?? 0;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(double currentProtein, double targetProtein, double currentEnergy, double targetEnergy, double weight, bool proteinMatch, bool energyMatch) {
    return CustomCard(
      isPremium: true,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Weight', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('${weight.toStringAsFixed(1)} kg', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            _buildResultRow('Crude Protein %', currentProtein, targetProtein, '%', proteinMatch),
            const SizedBox(height: 12),
            _buildResultRow('Metab. Energy', currentEnergy, targetEnergy, 'kcal/kg', energyMatch),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, double current, double target, String unit, bool isMatch) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text('${current.toStringAsFixed(1)} $unit', 
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: current > 0 ? (isMatch ? Colors.green : Colors.red) : Colors.black
                )
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text('Target', style: TextStyle(color: Colors.grey, fontSize: 12)),
            Text('${target.toStringAsFixed(1)} $unit', style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        )
      ],
    );
  }
}

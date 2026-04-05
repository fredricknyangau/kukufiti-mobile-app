import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../providers/data_providers.dart';
import '../../../core/utils/toast_service.dart';
import '../../../core/utils/error_handler.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_input.dart';

import '../../../core/network/api_client_provider.dart';
import '../../../providers/broiler_provider.dart';

class DailyChecksScreen extends ConsumerStatefulWidget {
  const DailyChecksScreen({super.key});

  @override
  ConsumerState<DailyChecksScreen> createState() => _DailyChecksScreenState();
}

class _DailyChecksScreenState extends ConsumerState<DailyChecksScreen> {
  final _tempController = TextEditingController();
  final _humidityController = TextEditingController();
  final _notesController = TextEditingController();
  String _behavior = 'normal';
  String _litter = 'dry';
  String _feed = 'adequate';
  String _water = 'full';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _tempController.dispose();
    _humidityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitCheck(String flockId) async {
    setState(() => _isSubmitting = true);
    try {
      final data = {
        'flock_id': flockId,
        'temperature_celsius': double.tryParse(_tempController.text),
        'humidity_percent': double.tryParse(_humidityController.text),
        'chick_behavior': _behavior,
        'litter_condition': _litter,
        'feed_level': _feed,
        'water_level': _water,
        'general_notes': _notesController.text,
        'check_date': DateTime.now().toIso8601String().split('T')[0],
      };

      // In a real app, we'd have a mutation in the provider or a service call.
      // For now we use the ApiClient directly or via a thin wrapper.
      // However, we'll assume the provider provides a submission mechanism soon or we use ApiClient.
      // Using ref.read(dailyChecksProvider(flockId).notifier) would be ideal if using AsyncNotifier.
      // But we'll just invalidate for now.
      
      await ref.read(apiClientProvider).post('daily-checks/', data: data);
      
      if (mounted) {
        ToastService.showSuccess(context, 'Daily check recorded successfully');
        ref.invalidate(dailyChecksProvider(flockId));
        _tempController.clear();
        _humidityController.clear();
        _notesController.clear();
      }
    } catch (e) {
      if (mounted) ToastService.showError(context, getFriendlyErrorMessage(e));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final broilerState = ref.watch(broilerProvider);
    final profileAsync = ref.watch(profileProvider);
    final user = profileAsync.value;
    final canEdit = user?.canEdit ?? false;
    final batch = broilerState.currentBatch;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Checks', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: broilerState.isLoading && batch == null
          ? const Center(child: CircularProgressIndicator())
          : batch == null
              ? const Center(child: Text('No active flock selected. Please select a flock to log checks.'))
              : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!canEdit)
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(LucideIcons.eye, color: Colors.amber, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Read-Only Mode: You do not have permission to log daily checks.',
                                    style: TextStyle(color: Colors.amber.shade900, fontSize: 13, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      CustomCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(LucideIcons.thermometer, color: theme.colorScheme.primary, size: 20),
                                const SizedBox(width: 8),
                                Text('Environmental Conditions', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomInput(
                                    label: 'Temp (°C)',
                                    hintText: '28.5',
                                    controller: _tempController,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: CustomInput(
                                    label: 'Humidity (%)',
                                    hintText: '65',
                                    controller: _humidityController,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      CustomCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(LucideIcons.eye, color: theme.colorScheme.primary, size: 20),
                                const SizedBox(width: 8),
                                Text('Observations', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _buildSelect('Chick Behavior', _behavior, ['normal', 'huddling', 'dispersed', 'panting', 'lethargic'], canEdit ? (v) => setState(() => _behavior = v!) : null),
                            const SizedBox(height: 16),
                            _buildSelect('Litter Condition', _litter, ['dry', 'damp', 'wet', 'caked'], canEdit ? (v) => setState(() => _litter = v!) : null),
                            const SizedBox(height: 16),
                            _buildSelect('Feed Level', _feed, ['full', 'adequate', 'low', 'empty'], canEdit ? (v) => setState(() => _feed = v!) : null),
                            const SizedBox(height: 16),
                            _buildSelect('Water Level', _water, ['full', 'adequate', 'low', 'empty'], canEdit ? (v) => setState(() => _water = v!) : null),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      CustomInput(
                        label: 'General Notes',
                        hintText: 'Anything else to report?',
                        controller: _notesController,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: 'Submit Daily Check',
                        onPressed: canEdit ? () => _submitCheck(batch.id) : null,
                        isLoading: _isSubmitting,
                        icon: const Icon(LucideIcons.check),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSelect(
    String label,
    String value,
    List<String> options,
    ValueChanged<String?>? onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: options.map((o) => DropdownMenuItem(value: o, child: Text(o.toUpperCase(), style: const TextStyle(fontSize: 13)))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

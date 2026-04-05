import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/models/broiler_models.dart';
import '../../../../providers/broiler_provider.dart';
import '../../../../presentation/widgets/custom_card.dart';
import '../../../../presentation/widgets/custom_divider.dart';
import '../../../../core/constants/broiler_constants.dart';
import '../../../../core/notifications/notification_service.dart';

class BatchDetailsScreen extends ConsumerStatefulWidget {
  final String batchId;
  const BatchDetailsScreen({super.key, required this.batchId});

  @override
  ConsumerState<BatchDetailsScreen> createState() => _BatchDetailsScreenState();
}

class _BatchDetailsScreenState extends ConsumerState<BatchDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduleVaccinations();
    });
  }

  Future<void> _scheduleVaccinations() async {
    final broilerState = ref.read(broilerProvider);
    final batch = broilerState.batches.firstWhere(
      (b) => b.id == widget.batchId,
      orElse: () => Batch(id: widget.batchId, name: '', commencementDate: DateTime.now(), initialChicks: 0, costPerChick: 0, totalCost: 0, status: 'active', breed: 'Unknown'),
    );

    if (batch.name.isEmpty) return;

    final box = Hive.box('offline_cache');
    final key = 'scheduled_vaccinations_${widget.batchId}';
    if (box.get(key) == true) return;

    for (var item in vaccinationSchedule) {
      final day = item['dayOfAge'] as int;
      final vaccine = item['name'] as String;
      final scheduledDate = batch.commencementDate.add(Duration(days: day));

      if (scheduledDate.isAfter(DateTime.now())) {
        await NotificationService.scheduleNotification(
          id: '${widget.batchId}_$day'.hashCode,
          title: 'Vaccination Appointment',
          body: '$vaccine required for batch ${batch.name} (Day $day)',
          scheduledDate: scheduledDate,
        );
      }
    }
    await box.put(key, true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final broilerState = ref.watch(broilerProvider);
    
    // Find the batch in the state
    final batch = broilerState.batches.firstWhere(
      (b) => b.id == widget.batchId,
      orElse: () => Batch(
        id: widget.batchId,
        name: 'Loading...',
        commencementDate: DateTime.now(),
        initialChicks: 0,
        costPerChick: 0,
        totalCost: 0,
        status: 'active',
        breed: 'Unknown',
      ),
    );

    if (batch.name == 'Loading...') {
       return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final daysActive = DateTime.now().difference(batch.commencementDate).inDays;

    return Scaffold(
      appBar: AppBar(
        title: Text(batch.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context, batch, daysActive),
            const SizedBox(height: 24),
            Text('Financial Summary', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildFinancialOverview(context, batch),
            const SizedBox(height: 24),
            Text('Quick Statistics', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildQuickStats(context, batch),
            const SizedBox(height: 24),
            _buildInfoList(context, batch),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Batch batch, int daysActive) {
    final theme = Theme.of(context);
    return CustomCard(
      isPremium: true,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(LucideIcons.layers, color: theme.colorScheme.primary, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(batch.status.toUpperCase(), 
                    style: TextStyle(
                      color: theme.colorScheme.primary, 
                      fontWeight: FontWeight.bold, 
                      fontSize: 12,
                      letterSpacing: 1.2
                    )
                  ),
                  Text(batch.name, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  Text('Day $daysActive of production', style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(150))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialOverview(BuildContext context, Batch batch) {
    return Row(
      children: [
        Expanded(
          child: _buildSimpleStat(context, 'Total Investment', 
            NumberFormat.currency(locale: 'en_KE', symbol: 'KES ').format(batch.totalCost),
            LucideIcons.banknote, Colors.blue),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSimpleStat(context, 'Cost per Bird', 
            NumberFormat.currency(locale: 'en_KE', symbol: 'KES ').format(batch.costPerChick),
            LucideIcons.tag, Colors.orange),
        ),
      ],
    );
  }

  Widget _buildQuickStats(BuildContext context, Batch batch) {
    return Row(
      children: [
        Expanded(
          child: _buildSimpleStat(context, 'Initial Chicks', 
            '${batch.initialChicks} birds',
            LucideIcons.users, Colors.green),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSimpleStat(context, 'Breed', 
            (batch.breed ?? 'Unknown').replaceAll('_', ' ').toUpperCase(),
            LucideIcons.info, Colors.purple),
        ),
      ],
    );
  }

  Widget _buildSimpleStat(BuildContext context, String label, String value, IconData icon, Color color) {
    return CustomCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildInfoList(BuildContext context, Batch batch) {
    return CustomCard(
      child: Column(
        children: [
          _infoRow(LucideIcons.calendar, 'Commencement Date', DateFormat('MMM dd, yyyy').format(batch.commencementDate)),
          if (batch.expectedEndDate != null) ...[
            const CustomDivider(),
            _infoRow(LucideIcons.calendarClock, 'Expected End Date', DateFormat('MMM dd, yyyy').format(batch.expectedEndDate!)),
          ],
          const CustomDivider(),
          _infoRow(LucideIcons.package, 'Hatchery Source', batch.hatcherySource ?? 'Not specified'),
          const CustomDivider(),
          _infoRow(LucideIcons.mapPin, 'Source Location', batch.sourceLocation ?? 'Not specified'),
          if (batch.notes?.isNotEmpty == true) ...[
            const CustomDivider(),
            _infoRow(LucideIcons.fileText, 'Notes', batch.notes!),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, size: 20, color: Colors.grey),
      title: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      subtitle: Text(value, style: TextStyle(fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
      dense: true,
    );
  }
}

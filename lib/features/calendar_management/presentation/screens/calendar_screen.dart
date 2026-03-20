import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../presentation/widgets/app_drawer.dart';
import '../../../../presentation/widgets/custom_card.dart';
import '../../../../providers/data_providers.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();

    final mortalityAsync = ref.watch(mortalityProvider);
    final feedAsync = ref.watch(feedProvider);
    final vaccinationAsync = ref.watch(vaccinationProvider);
    final weightAsync = ref.watch(weightProvider);
    final tasksAsync = ref.watch(tasksProvider);

    if (mortalityAsync.isLoading || feedAsync.isLoading || vaccinationAsync.isLoading || weightAsync.isLoading || tasksAsync.isLoading) {
      return Scaffold(
        drawer: const AppDrawer(),
        appBar: AppBar(title: const Text('Calendar')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final allEvents = <Map<String, dynamic>>[];
    
    // Aggregate Mortality
    for (final e in mortalityAsync.value ?? []) {
      if (e['event_date'] != null) {
        allEvents.add({
          'type': 'mortality',
          'date': DateTime.parse(e['event_date']),
          'title': 'Mortality: ${e['count']} birds',
          'description': e['notes'] ?? '',
          'icon': LucideIcons.skull,
          'color': theme.colorScheme.error,
        });
      }
    }
    
    // Aggregate Feed
    for (final e in feedAsync.value ?? []) {
      if (e['event_date'] != null) {
        allEvents.add({
          'type': 'feed',
          'date': DateTime.parse(e['event_date']),
          'title': 'Feed: ${e['quantity_kg']} kg',
          'description': e['feed_type'] ?? '',
          'icon': LucideIcons.wheat,
          'color': Colors.blue,
        });
      }
    }
    
    // Aggregate Vaccination
    for (final e in vaccinationAsync.value ?? []) {
      if (e['event_date'] != null) {
        allEvents.add({
          'type': 'vaccination',
          'date': DateTime.parse(e['event_date']),
          'title': 'Vaccine: ${e['vaccine_name']}',
          'description': (e['administration_method'] ?? '').toString().replaceAll('_', ' ').toUpperCase(),
          'icon': LucideIcons.syringe,
          'color': Colors.purple,
        });
      }
    }
    
    // Aggregate Weight
    for (final e in weightAsync.value ?? []) {
      if (e['event_date'] != null) {
        allEvents.add({
          'type': 'weight',
          'date': DateTime.parse(e['event_date']),
          'title': 'Weight Check: ${e['average_weight_grams']}g',
          'description': '',
          'icon': LucideIcons.scale,
          'color': Colors.green,
        });
      }
    }

    // Aggregate Tasks
    for (final e in tasksAsync.value ?? []) {
      if (e['due_date'] != null) {
        allEvents.add({
          'type': 'task',
          'date': DateTime.parse(e['due_date']),
          'title': e['title'] ?? 'Task',
          'description': e['description'] ?? '',
          'icon': LucideIcons.calendarCheck2,
          'color': Colors.orange,
        });
      }
    }

    final selectedDateEvents = allEvents.where((e) {
      final evtDate = e['date'] as DateTime;
      return evtDate.year == _selectedDate.year &&
             evtDate.month == _selectedDate.month &&
             evtDate.day == _selectedDate.day;
    }).toList();

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Calendar', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(LucideIcons.plus), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomCard(
              isPremium: true,
              child: CalendarDatePicker(
                initialDate: _selectedDate,
                firstDate: now.subtract(const Duration(days: 365)),
                lastDate: now.add(const Duration(days: 365)),
                onDateChanged: (date) {
                  setState(() => _selectedDate = date);
                },
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '${DateFormat('MMMM d, yyyy').format(_selectedDate)} Events',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (selectedDateEvents.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text(
                    'No events scheduled for this day.',
                    style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                  ),
                ),
              )
            else
              ...selectedDateEvents.map((evt) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CustomCard(
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (evt['color'] as Color).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(evt['icon'] as IconData, color: evt['color'] as Color),
                    ),
                    title: Text(evt['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: evt['description'].toString().isNotEmpty 
                        ? Text(evt['description'] as String) 
                        : null,
                  ),
                ),
              )),
          ],
        ),
      ),
    );
  }
}

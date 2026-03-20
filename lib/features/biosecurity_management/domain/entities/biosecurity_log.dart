class BiosecurityLog {
  final String id;
  final List<Map<String, dynamic>> items;
  final String completedBy;
  final String notes;
  final DateTime date;

  BiosecurityLog({
    required this.id,
    required this.items,
    required this.completedBy,
    required this.notes,
    required this.date,
  });

  String get status => items.every((e) => e['completed'] == true) ? 'Compliant' : 'Needs Attention';
}

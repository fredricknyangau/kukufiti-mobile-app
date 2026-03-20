class Alert {
  final int id;
  final String title;
  final String message;
  final String severity; // 'critical' | 'error' | 'warning' | 'info'
  final DateTime createdAt;

  Alert({
    required this.id,
    required this.title,
    required this.message,
    required this.severity,
    required this.createdAt,
  });
}

import '../../domain/entities/alert.dart';

class AlertDto {
  final int id;
  final String title;
  final String message;
  final String severity;
  final DateTime createdAt;

  AlertDto({
    required this.id,
    required this.title,
    required this.message,
    required this.severity,
    required this.createdAt,
  });

  factory AlertDto.fromJson(Map<String, dynamic> json) {
    return AlertDto(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Alert',
      message: json['message'] ?? '',
      severity: json['severity']?.toString().toLowerCase() ?? 'info',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Alert toEntity() {
    return Alert(
      id: id,
      title: title,
      message: message,
      severity: severity,
      createdAt: createdAt,
    );
  }
}

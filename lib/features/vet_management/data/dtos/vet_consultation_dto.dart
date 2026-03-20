import '../../domain/entities/vet_consultation.dart';

class VetConsultationDto {
  final int id;
  final String reason;
  final String status;
  final DateTime date;

  VetConsultationDto({
    required this.id,
    required this.reason,
    required this.status,
    required this.date,
  });

  factory VetConsultationDto.fromJson(Map<String, dynamic> json) {
    return VetConsultationDto(
      id: json['id'] ?? 0,
      reason: json['reason'] ?? 'Consultation',
      status: json['status'] ?? 'Completed',
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  VetConsultation toEntity() {
    return VetConsultation(
      id: id,
      reason: reason,
      status: status,
      date: date,
    );
  }
}

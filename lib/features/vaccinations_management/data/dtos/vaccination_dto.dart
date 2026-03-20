import '../../domain/entities/vaccination.dart';

class VaccinationDto {
  final String id;
  final String vaccineName;
  final String diseaseTarget;
  final String method;
  final bool completed;
  final DateTime date;

  VaccinationDto({
    required this.id,
    required this.vaccineName,
    required this.diseaseTarget,
    required this.method,
    required this.completed,
    required this.date,
  });

  factory VaccinationDto.fromJson(Map<String, dynamic> json) {
    return VaccinationDto(
      id: json['id']?.toString() ?? '',
      vaccineName: json['vaccine_name'] ?? json['name'] ?? 'Unknown Vaccine',
      diseaseTarget: json['disease_target'] ?? 'General',
      method: json['administration_method'] ?? json['method'] ?? 'Drinking Water',
      completed: json['completed'] ?? true, // optional or assumed true if logged
      date: DateTime.tryParse(json['event_date']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Vaccination toEntity() {
    return Vaccination(
      id: id,
      vaccineName: vaccineName,
      diseaseTarget: diseaseTarget,
      method: method,
      completed: completed,
      date: date,
    );
  }
}

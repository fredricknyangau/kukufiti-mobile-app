import 'package:mobile/features/vaccinations_management/domain/entities/vaccination.dart';

class VaccinationDto {
  final String id;
  final String vaccineName;
  final String diseaseTarget;
  final String method;
  final bool completed;
  final DateTime date;
  final double? costKsh;

  VaccinationDto({
    required this.id,
    required this.vaccineName,
    required this.diseaseTarget,
    required this.method,
    required this.completed,
    required this.date,
    this.costKsh,
  });

  factory VaccinationDto.fromJson(Map<String, dynamic> json) {
    return VaccinationDto(
      id: json['id']?.toString() ?? '',
      vaccineName: json['vaccine_name'] ?? json['name'] ?? 'Unknown Vaccine',
      diseaseTarget: json['disease_target'] ?? 'General',
      method: json['administration_method'] ?? json['method'] ?? 'Drinking Water',
      completed: json['completed'] ?? true,
      date: DateTime.tryParse(json['event_date']?.toString() ?? '') ?? DateTime.now(),
      costKsh: (json['cost_ksh'] as num?)?.toDouble(),
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
      costKsh: costKsh,
    );
  }
}

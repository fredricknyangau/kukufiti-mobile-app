import '../../domain/entities/mortality.dart';

class MortalityDto {
  final String id;
  final int count;
  final String cause;
  final DateTime date;

  MortalityDto({
    required this.id,
    required this.count,
    required this.cause,
    required this.date,
  });

  factory MortalityDto.fromJson(Map<String, dynamic> json) {
    return MortalityDto(
      id: json['id']?.toString() ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0,
      cause: json['cause'] ?? 'Unknown',
      date: DateTime.tryParse(json['event_date']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Mortality toEntity() {
    return Mortality(
      id: id,
      count: count,
      cause: cause,
      date: date,
    );
  }
}

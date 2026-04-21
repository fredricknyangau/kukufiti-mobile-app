import 'package:mobile/features/weight_management/domain/entities/weight_record.dart';

class WeightRecordDto {
  final String id;
  final int sampleSize;
  final double averageWeight;
  final DateTime date;

  WeightRecordDto({
    required this.id,
    required this.sampleSize,
    required this.averageWeight,
    required this.date,
  });

  factory WeightRecordDto.fromJson(Map<String, dynamic> json) {
    return WeightRecordDto(
      id: json['id']?.toString() ?? '',
      sampleSize: json['sample_size'] ?? 1,
      averageWeight: (json['average_weight_grams'] as num?)?.toDouble() ?? 
                     (json['average_weight'] as num?)?.toDouble() ?? 0.0,
      date: DateTime.tryParse(json['event_date']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  WeightRecord toEntity() {
    return WeightRecord(
      id: id,
      sampleSize: sampleSize,
      averageWeight: averageWeight,
      date: date,
    );
  }
}

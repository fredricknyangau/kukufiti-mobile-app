import 'package:mobile/features/flock_management/domain/entities/flock.dart';

class FlockDto {
  final int id;
  final String name;
  final int batchSize;
  final String status;

  FlockDto({
    required this.id,
    required this.name,
    required this.batchSize,
    required this.status,
  });

  factory FlockDto.fromJson(Map<String, dynamic> json) {
    return FlockDto(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      batchSize: json['batch_size'] ?? json['size'] ?? json['initial_chicks'] ?? 0,
      status: json['status'] ?? 'Active',
    );
  }

  Flock toEntity() {
    return Flock(
      id: id,
      name: name,
      batchSize: batchSize,
      status: status,
    );
  }
}

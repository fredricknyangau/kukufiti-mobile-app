import '../../domain/entities/biosecurity_log.dart';

class BiosecurityLogDto {
  final String id;
  final List<Map<String, dynamic>> items;
  final String completedBy;
  final String notes;
  final DateTime date;

  BiosecurityLogDto({
    required this.id,
    required this.items,
    required this.completedBy,
    required this.notes,
    required this.date,
  });

  factory BiosecurityLogDto.fromJson(Map<String, dynamic> json) {
    return BiosecurityLogDto(
      id: json['id']?.toString() ?? '',
      items: (json['items'] as List?)?.map((e) => Map<String, dynamic>.from(e)).toList() ?? [],
      completedBy: json['completed_by'] ?? 'Unknown',
      notes: json['notes'] ?? '',
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  BiosecurityLog toEntity() {
    return BiosecurityLog(
      id: id,
      items: items,
      completedBy: completedBy,
      notes: notes,
      date: date,
    );
  }
}

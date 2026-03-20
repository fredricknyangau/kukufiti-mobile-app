import '../../domain/entities/feed_record.dart';

class FeedRecordDto {
  final String id;
  final double amount;
  final String feedType;
  final DateTime date;

  FeedRecordDto({
    required this.id,
    required this.amount,
    required this.feedType,
    required this.date,
  });

  factory FeedRecordDto.fromJson(Map<String, dynamic> json) {
    return FeedRecordDto(
      id: json['id']?.toString() ?? '',
      amount: (json['quantity_kg'] as num?)?.toDouble() ?? 0.0,
      feedType: json['feed_type'] ?? 'Standard',
      date: DateTime.tryParse(json['event_date']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  FeedRecord toEntity() {
    return FeedRecord(
      id: id,
      amount: amount,
      feedType: feedType,
      date: date,
    );
  }
}

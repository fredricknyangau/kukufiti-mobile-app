import 'package:mobile/features/analytics_management/domain/entities/finance_spot.dart';

class FinanceSpotDto {
  final DateTime date;
  final double revenue;
  final double expenses;

  FinanceSpotDto({
    required this.date,
    required this.revenue,
    required this.expenses,
  });

  factory FinanceSpotDto.fromJson(Map<String, dynamic> json) {
    return FinanceSpotDto(
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
      expenses: (json['expenses'] as num?)?.toDouble() ?? 0.0,
    );
  }

  FinanceSpot toEntity() {
    return FinanceSpot(
      date: date,
      revenue: revenue,
      expenses: expenses,
    );
  }
}

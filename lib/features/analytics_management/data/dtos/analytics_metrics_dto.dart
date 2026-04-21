import 'package:mobile/features/analytics_management/domain/entities/analytics_metrics.dart';

class AnalyticsMetricsDto {
  final double mortalityRate;
  final int activeFlocks;
  final int currentBirds;

  AnalyticsMetricsDto({
    required this.mortalityRate,
    required this.activeFlocks,
    required this.currentBirds,
  });

  factory AnalyticsMetricsDto.fromJson(Map<String, dynamic> json) {
    return AnalyticsMetricsDto(
      mortalityRate: (json['mortality_rate'] as num?)?.toDouble() ?? 0.0,
      activeFlocks: json['active_flocks'] ?? 0,
      currentBirds: json['current_birds'] ?? 0,
    );
  }

  AnalyticsMetrics toEntity() {
    return AnalyticsMetrics(
      mortalityRate: mortalityRate,
      activeFlocks: activeFlocks,
      currentBirds: currentBirds,
    );
  }
}

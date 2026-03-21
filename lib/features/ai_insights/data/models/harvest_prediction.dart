class HarvestPredictionRequest {
  final int flockAgeDays;
  final double currentAvgWeightKg;
  final double targetWeightKg;
  final String breed;

  HarvestPredictionRequest({
    required this.flockAgeDays,
    required this.currentAvgWeightKg,
    required this.targetWeightKg,
    required this.breed,
  });

  Map<String, dynamic> toJson() => {
        'flock_age_days': flockAgeDays,
        'current_avg_weight_kg': currentAvgWeightKg,
        'target_weight_kg': targetWeightKg,
        'breed': breed,
      };
}

class HarvestPredictionResponse {
  final int estimatedDaysToTarget;
  final double dailyGainEstimateG;
  final String statusFlag;
  final List<String> recommendations;

  HarvestPredictionResponse({
    required this.estimatedDaysToTarget,
    required this.dailyGainEstimateG,
    required this.statusFlag,
    required this.recommendations,
  });

  factory HarvestPredictionResponse.fromJson(Map<String, dynamic> json) {
    return HarvestPredictionResponse(
      estimatedDaysToTarget: json['estimated_days_to_target'] ?? 0,
      dailyGainEstimateG: (json['daily_gain_estimate_g'] as num).toDouble(),
      statusFlag: json['status_flag'] ?? 'UNKNOWN',
      recommendations: List<String>.from(json['recommendations'] ?? []),
    );
  }
}

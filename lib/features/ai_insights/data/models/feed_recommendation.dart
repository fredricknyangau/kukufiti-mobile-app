class FeedRecommendationRequest {
  final int flockAgeDays;
  final double currentAvgWeightKg;
  final String breed;
  final int birdCount;

  FeedRecommendationRequest({
    required this.flockAgeDays,
    required this.currentAvgWeightKg,
    required this.breed,
    required this.birdCount,
  });

  Map<String, dynamic> toJson() => {
        'flock_age_days': flockAgeDays,
        'current_avg_weight_kg': currentAvgWeightKg,
        'breed': breed,
        'bird_count': birdCount,
      };
}

class FeedRecommendationResponse {
  final double recommendedDailyKg;
  final String statusFlag;
  final String reasoningExplanation;
  final String confidenceLevel;

  FeedRecommendationResponse({
    required this.recommendedDailyKg,
    required this.statusFlag,
    required this.reasoningExplanation,
    required this.confidenceLevel,
  });

  factory FeedRecommendationResponse.fromJson(Map<String, dynamic> json) {
    return FeedRecommendationResponse(
      recommendedDailyKg: (json['recommended_daily_kg'] as num).toDouble(),
      statusFlag: json['status_flag'] ?? 'UNKNOWN',
      reasoningExplanation: json['reasoning_explanation'] ?? '',
      confidenceLevel: json['confidence_level'] ?? 'UNKNOWN',
    );
  }
}

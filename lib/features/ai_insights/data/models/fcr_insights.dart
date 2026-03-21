class FcrInsightsRequest {
  final double totalFeedConsumedKg;
  final double currentAvgWeightKg;
  final int initialBirdCount;
  final int currentBirdCount;

  FcrInsightsRequest({
    required this.totalFeedConsumedKg,
    required this.currentAvgWeightKg,
    required this.initialBirdCount,
    required this.currentBirdCount,
  });

  Map<String, dynamic> toJson() => {
        'total_feed_consumed_kg': totalFeedConsumedKg,
        'current_avg_weight_kg': currentAvgWeightKg,
        'initial_bird_count': initialBirdCount,
        'current_bird_count': currentBirdCount,
      };
}

class FcrInsightsResponse {
  final double estimatedFcr;
  final String benchmarkStatus;
  final String costImpactExplanation;
  final List<String> recommendations;

  FcrInsightsResponse({
    required this.estimatedFcr,
    required this.benchmarkStatus,
    required this.costImpactExplanation,
    required this.recommendations,
  });

  factory FcrInsightsResponse.fromJson(Map<String, dynamic> json) {
    return FcrInsightsResponse(
      estimatedFcr: (json['estimated_fcr'] as num).toDouble(),
      benchmarkStatus: json['benchmark_status'] ?? 'UNKNOWN',
      costImpactExplanation: json['cost_impact_explanation'] ?? '',
      recommendations: List<String>.from(json['recommendations'] ?? []),
    );
  }
}

class MortalityLogEntry {
  final String date;
  final int count;
  final String? cause;

  MortalityLogEntry({
    required this.date,
    required this.count,
    this.cause,
  });

  Map<String, dynamic> toJson() => {
        'date': date,
        'count': count,
        if (cause != null) 'cause': cause,
      };

  factory MortalityLogEntry.fromJson(Map<String, dynamic> json) {
    return MortalityLogEntry(
      date: json['date'] ?? '',
      count: json['count'] ?? 0,
      cause: json['cause'],
    );
  }
}

class MortalityAnalysisRequest {
  final String? flockId;
  final String breed;
  final int initialBirdCount;
  final int currentBirdCount;
  final List<MortalityLogEntry> recentMortality;

  MortalityAnalysisRequest({
    this.flockId,
    required this.breed,
    required this.initialBirdCount,
    required this.currentBirdCount,
    required this.recentMortality,
  });

  Map<String, dynamic> toJson() => {
        if (flockId != null) 'flock_id': flockId,
        'breed': breed,
        'initial_bird_count': initialBirdCount,
        'current_bird_count': currentBirdCount,
        'recent_mortality': recentMortality.map((e) => e.toJson()).toList(),
      };
}

class MortalityAnalysisResponse {
  final String alertLevel;
  final bool thresholdExceeded;
  final double cumulativeMortalityRate;
  final List<String> potentialCauses;
  final List<String> recommendations;
  final double confidenceScore;

  MortalityAnalysisResponse({
    required this.alertLevel,
    required this.thresholdExceeded,
    required this.cumulativeMortalityRate,
    required this.potentialCauses,
    required this.recommendations,
    required this.confidenceScore,
  });

  factory MortalityAnalysisResponse.fromJson(Map<String, dynamic> json) {
    return MortalityAnalysisResponse(
      alertLevel: json['alert_level'] ?? 'NORMAL',
      thresholdExceeded: json['threshold_exceeded'] ?? false,
      cumulativeMortalityRate: (json['cumulative_mortality_rate'] as num).toDouble(),
      potentialCauses: List<String>.from(json['potential_causes'] ?? []),
      recommendations: List<String>.from(json['recommendations'] ?? []),
      confidenceScore: (json['confidence_score'] as num).toDouble(),
    );
  }
}

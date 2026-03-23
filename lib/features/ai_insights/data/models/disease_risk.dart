class DiseaseRiskRequest {
  final List<String> symptoms;
  final List<String> recentVaccinations;
  final String mortalityAlertLevel;
  final String? imageBase64;

  DiseaseRiskRequest({
    required this.symptoms,
    required this.recentVaccinations,
    this.mortalityAlertLevel = 'NORMAL',
    this.imageBase64,
  });

  Map<String, dynamic> toJson() => {
        'symptoms': symptoms,
        'recent_vaccinations': recentVaccinations,
        'mortality_alert_level': mortalityAlertLevel,
        'image_base64': imageBase64,
      };
}

class DiseaseRiskResponse {
  final List<String> suspectedConditions;
  final String riskLevel;
  final List<String> missedCriticalVaccines;
  final List<String> recommendations;

  DiseaseRiskResponse({
    required this.suspectedConditions,
    required this.riskLevel,
    required this.missedCriticalVaccines,
    required this.recommendations,
  });

  factory DiseaseRiskResponse.fromJson(Map<String, dynamic> json) {
    return DiseaseRiskResponse(
      suspectedConditions: List<String>.from(json['suspected_conditions'] ?? []),
      riskLevel: json['risk_level'] ?? 'LOW',
      missedCriticalVaccines: List<String>.from(json['missed_critical_vaccines'] ?? []),
      recommendations: List<String>.from(json['recommendations'] ?? []),
    );
  }
}

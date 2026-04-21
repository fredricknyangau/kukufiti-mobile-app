class Vaccination {
  final String id;
  final String vaccineName;
  final String diseaseTarget;
  final String method;
  final bool completed;
  final DateTime date;
  final double? costKsh;

  Vaccination({
    required this.id,
    required this.vaccineName,
    required this.diseaseTarget,
    required this.method,
    required this.completed,
    required this.date,
    this.costKsh,
  });
}

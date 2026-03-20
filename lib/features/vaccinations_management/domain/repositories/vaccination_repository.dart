import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/vaccination.dart';

abstract class VaccinationRepository {
  Future<Either<Failure, List<Vaccination>>> getVaccinations();
  Future<Either<Failure, void>> logVaccination({
    required String flockId,
    required String vaccineName,
    required String diseaseTarget,
    required String method,
    required DateTime date,
  });
}

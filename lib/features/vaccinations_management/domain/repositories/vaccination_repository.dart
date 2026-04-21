import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/features/vaccinations_management/domain/entities/vaccination.dart';

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

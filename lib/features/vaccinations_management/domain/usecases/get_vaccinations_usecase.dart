import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/usecases/usecase.dart';
import 'package:mobile/features/vaccinations_management/domain/entities/vaccination.dart';
import 'package:mobile/features/vaccinations_management/domain/repositories/vaccination_repository.dart';

class GetVaccinationsUseCase implements UseCase<List<Vaccination>, NoParams> {
  final VaccinationRepository repository;

  GetVaccinationsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Vaccination>>> call(NoParams params) {
    return repository.getVaccinations();
  }
}

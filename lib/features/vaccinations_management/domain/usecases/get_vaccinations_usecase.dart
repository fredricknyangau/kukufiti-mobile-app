import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/vaccination.dart';
import '../repositories/vaccination_repository.dart';

class GetVaccinationsUseCase implements UseCase<List<Vaccination>, NoParams> {
  final VaccinationRepository repository;

  GetVaccinationsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Vaccination>>> call(NoParams params) {
    return repository.getVaccinations();
  }
}

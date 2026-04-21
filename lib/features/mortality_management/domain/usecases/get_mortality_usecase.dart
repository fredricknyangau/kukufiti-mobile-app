import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/usecases/usecase.dart';
import 'package:mobile/features/mortality_management/domain/entities/mortality.dart';
import 'package:mobile/features/mortality_management/domain/repositories/mortality_repository.dart';

class GetMortalityUseCase implements UseCase<List<Mortality>, NoParams> {
  final MortalityRepository repository;

  GetMortalityUseCase(this.repository);

  @override
  Future<Either<Failure, List<Mortality>>> call(NoParams params) {
    return repository.getMortalityRecords();
  }
}

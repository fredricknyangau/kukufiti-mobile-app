import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/mortality.dart';
import '../repositories/mortality_repository.dart';

class GetMortalityUseCase implements UseCase<List<Mortality>, NoParams> {
  final MortalityRepository repository;

  GetMortalityUseCase(this.repository);

  @override
  Future<Either<Failure, List<Mortality>>> call(NoParams params) {
    return repository.getMortalityRecords();
  }
}

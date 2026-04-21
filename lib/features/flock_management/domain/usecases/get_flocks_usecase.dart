import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/usecases/usecase.dart';
import 'package:mobile/features/flock_management/domain/entities/flock.dart';
import 'package:mobile/features/flock_management/domain/repositories/flock_repository.dart';

class GetFlocksUseCase implements UseCase<List<Flock>, NoParams> {
  final FlockRepository repository;

  GetFlocksUseCase(this.repository);

  @override
  Future<Either<Failure, List<Flock>>> call(NoParams params) {
    return repository.getFlocks();
  }
}

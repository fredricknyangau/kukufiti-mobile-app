import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/flock.dart';
import '../repositories/flock_repository.dart';

class GetFlocksUseCase implements UseCase<List<Flock>, NoParams> {
  final FlockRepository repository;

  GetFlocksUseCase(this.repository);

  @override
  Future<Either<Failure, List<Flock>>> call(NoParams params) {
    return repository.getFlocks();
  }
}

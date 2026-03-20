import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/biosecurity_log.dart';
import '../repositories/biosecurity_repository.dart';

class GetBiosecurityLogsUseCase implements UseCase<List<BiosecurityLog>, NoParams> {
  final BiosecurityRepository repository;

  GetBiosecurityLogsUseCase(this.repository);

  @override
  Future<Either<Failure, List<BiosecurityLog>>> call(NoParams params) {
    return repository.getLogs();
  }
}

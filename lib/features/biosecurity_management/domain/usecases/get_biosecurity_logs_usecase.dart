import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/usecases/usecase.dart';
import 'package:mobile/features/biosecurity_management/domain/entities/biosecurity_log.dart';
import 'package:mobile/features/biosecurity_management/domain/repositories/biosecurity_repository.dart';

class GetBiosecurityLogsUseCase implements UseCase<List<BiosecurityLog>, NoParams> {
  final BiosecurityRepository repository;

  GetBiosecurityLogsUseCase(this.repository);

  @override
  Future<Either<Failure, List<BiosecurityLog>>> call(NoParams params) {
    return repository.getLogs();
  }
}

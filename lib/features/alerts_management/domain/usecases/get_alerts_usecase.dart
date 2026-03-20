import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/alert.dart';
import '../repositories/alert_repository.dart';

class GetAlertsUseCase implements UseCase<List<Alert>, NoParams> {
  final AlertRepository repository;

  GetAlertsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Alert>>> call(NoParams params) {
    return repository.getAlerts();
  }
}

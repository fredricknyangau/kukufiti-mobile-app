import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/usecases/usecase.dart';
import 'package:mobile/features/alerts_management/domain/entities/alert.dart';
import 'package:mobile/features/alerts_management/domain/repositories/alert_repository.dart';

class GetAlertsUseCase implements UseCase<List<Alert>, NoParams> {
  final AlertRepository repository;

  GetAlertsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Alert>>> call(NoParams params) {
    return repository.getAlerts();
  }
}

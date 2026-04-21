import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/features/alerts_management/domain/entities/alert.dart';

abstract class AlertRepository {
  Future<Either<Failure, List<Alert>>> getAlerts();
}

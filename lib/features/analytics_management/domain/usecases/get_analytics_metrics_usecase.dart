import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/usecases/usecase.dart';
import 'package:mobile/features/analytics_management/domain/entities/analytics_metrics.dart';
import 'package:mobile/features/analytics_management/domain/repositories/analytics_repository.dart';

class GetAnalyticsMetricsUseCase implements UseCase<AnalyticsMetrics, NoParams> {
  final AnalyticsRepository repository;

  GetAnalyticsMetricsUseCase(this.repository);

  @override
  Future<Either<Failure, AnalyticsMetrics>> call(NoParams params) {
    return repository.getDashboardMetrics();
  }
}

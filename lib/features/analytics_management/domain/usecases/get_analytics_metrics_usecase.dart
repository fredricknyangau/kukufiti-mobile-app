import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/analytics_metrics.dart';
import '../repositories/analytics_repository.dart';

class GetAnalyticsMetricsUseCase implements UseCase<AnalyticsMetrics, NoParams> {
  final AnalyticsRepository repository;

  GetAnalyticsMetricsUseCase(this.repository);

  @override
  Future<Either<Failure, AnalyticsMetrics>> call(NoParams params) {
    return repository.getDashboardMetrics();
  }
}

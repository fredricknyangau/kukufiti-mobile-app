import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/usecases/usecase.dart';
import 'package:mobile/features/analytics_management/domain/entities/finance_spot.dart';
import 'package:mobile/features/analytics_management/domain/repositories/analytics_repository.dart';

class GetFinanceSpotsUseCase implements UseCase<List<FinanceSpot>, NoParams> {
  final AnalyticsRepository repository;

  GetFinanceSpotsUseCase(this.repository);

  @override
  Future<Either<Failure, List<FinanceSpot>>> call(NoParams params) {
    return repository.getFinancialChartData();
  }
}

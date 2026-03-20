import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/finance_spot.dart';
import '../repositories/analytics_repository.dart';

class GetFinanceSpotsUseCase implements UseCase<List<FinanceSpot>, NoParams> {
  final AnalyticsRepository repository;

  GetFinanceSpotsUseCase(this.repository);

  @override
  Future<Either<Failure, List<FinanceSpot>>> call(NoParams params) {
    return repository.getFinancialChartData();
  }
}

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/analytics_metrics.dart';
import '../entities/finance_spot.dart';

abstract class AnalyticsRepository {
  Future<Either<Failure, AnalyticsMetrics>> getDashboardMetrics();
  Future<Either<Failure, List<FinanceSpot>>> getFinancialChartData();
}

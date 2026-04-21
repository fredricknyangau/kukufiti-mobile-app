import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/features/analytics_management/domain/entities/analytics_metrics.dart';
import 'package:mobile/features/analytics_management/domain/entities/finance_spot.dart';

abstract class AnalyticsRepository {
  Future<Either<Failure, AnalyticsMetrics>> getDashboardMetrics();
  Future<Either<Failure, List<FinanceSpot>>> getFinancialChartData();
}

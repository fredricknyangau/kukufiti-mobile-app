import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/network/api_endpoints.dart';
import 'package:mobile/features/analytics_management/domain/entities/analytics_metrics.dart';
import 'package:mobile/features/analytics_management/domain/entities/finance_spot.dart';
import 'package:mobile/features/analytics_management/domain/repositories/analytics_repository.dart';
import 'package:mobile/features/analytics_management/data/dtos/analytics_metrics_dto.dart';
import 'package:mobile/features/analytics_management/data/dtos/finance_spot_dto.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final Dio apiClient;

  AnalyticsRepositoryImpl(this.apiClient);

  @override
  Future<Either<Failure, AnalyticsMetrics>> getDashboardMetrics() async {
    try {
      final response = await apiClient.get(ApiEndpoints.dashboardMetrics);
      final responseData = response.data;

      final Map<String, dynamic> data = (responseData is Map<String, dynamic> && responseData.containsKey('data'))
          ? responseData['data']
          : responseData;

      final item = AnalyticsMetricsDto.fromJson(data).toEntity();
      return Right(item);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FinanceSpot>>> getFinancialChartData() async {
    try {
      final response = await apiClient.get(ApiEndpoints.financialChart);
      final responseData = response.data;

      final List data = (responseData is Map<String, dynamic> && responseData.containsKey('data'))
          ? responseData['data']
          : responseData;

      final items = data.map((json) => FinanceSpotDto.fromJson(json).toEntity()).toList();
      return Right(items);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

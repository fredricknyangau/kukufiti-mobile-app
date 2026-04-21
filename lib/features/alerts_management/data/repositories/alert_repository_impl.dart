import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/network/api_endpoints.dart';
import 'package:mobile/features/alerts_management/domain/entities/alert.dart';
import 'package:mobile/features/alerts_management/domain/repositories/alert_repository.dart';
import 'package:mobile/features/alerts_management/data/dtos/alert_dto.dart';

class AlertRepositoryImpl implements AlertRepository {
  final Dio apiClient;

  AlertRepositoryImpl(this.apiClient);

  @override
  Future<Either<Failure, List<Alert>>> getAlerts() async {
    try {
      final response = await apiClient.get(ApiEndpoints.alerts);
      final responseData = response.data;

      final List data = (responseData is Map<String, dynamic> && responseData.containsKey('data'))
          ? responseData['data']
          : responseData;

      final items = data.map((json) => AlertDto.fromJson(json).toEntity()).toList();
      return Right(items);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/alert.dart';
import '../../domain/repositories/alert_repository.dart';
import '../dtos/alert_dto.dart';

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

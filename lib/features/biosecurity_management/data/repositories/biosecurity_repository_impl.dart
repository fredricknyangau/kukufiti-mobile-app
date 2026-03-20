import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/biosecurity_log.dart';
import '../../domain/repositories/biosecurity_repository.dart';
import '../dtos/biosecurity_log_dto.dart';

class BiosecurityRepositoryImpl implements BiosecurityRepository {
  final Dio apiClient;

  BiosecurityRepositoryImpl(this.apiClient);

  @override
  Future<Either<Failure, List<BiosecurityLog>>> getLogs() async {
    try {
      final response = await apiClient.get(ApiEndpoints.biosecurity);
      final responseData = response.data;

      final List data = (responseData is Map<String, dynamic> && responseData.containsKey('data'))
          ? responseData['data']
          : responseData;

      final items = data.map((json) => BiosecurityLogDto.fromJson(json).toEntity()).toList();
      return Right(items);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> submitChecklist({
    required List<Map<String, dynamic>> items,
    required String completedBy,
    required String notes,
    required DateTime date,
  }) async {
    try {
      await apiClient.post(ApiEndpoints.biosecurity, data: {
        'items': items,
        'completed_by': completedBy,
        'notes': notes,
        'date': date.toIso8601String().split('T')[0],
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

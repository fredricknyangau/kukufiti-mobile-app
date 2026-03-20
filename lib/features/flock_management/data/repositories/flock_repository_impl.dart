import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/flock.dart';
import '../../domain/repositories/flock_repository.dart';
import '../dtos/flock_dto.dart';

class FlockRepositoryImpl implements FlockRepository {
  final Dio apiClient;

  FlockRepositoryImpl(this.apiClient);

  @override
  Future<Either<Failure, List<Flock>>> getFlocks() async {
    try {
      final response = await apiClient.get(ApiEndpoints.batches);
      final responseData = response.data;

      final List data = (responseData is Map<String, dynamic> && responseData.containsKey('data'))
          ? responseData['data']
          : responseData;

      final flocks = data.map((json) => FlockDto.fromJson(json).toEntity()).toList();
      return Right(flocks);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createFlock({required String name, required int batchSize}) async {
    try {
      final today = DateTime.now().toIso8601String().split('T').first; // 'YYYY-MM-DD'
      await apiClient.post(ApiEndpoints.batches, data: {
        'name': name,
        'batch_size': batchSize,
        'initial_count': batchSize,
        'status': 'active',
        'start_date': today,
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateFlock({required int id, required String name, required int batchSize}) async {
    try {
      await apiClient.put('${ApiEndpoints.batches}$id', data: {
        'name': name,
        'batch_size': batchSize,
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteFlock(int id) async {
    try {
      await apiClient.delete('${ApiEndpoints.batches}$id');
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

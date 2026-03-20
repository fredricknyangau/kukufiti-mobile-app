import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/weight_record.dart';
import '../../domain/repositories/weight_repository.dart';
import '../dtos/weight_record_dto.dart';

class WeightRepositoryImpl implements WeightRepository {
  final Dio apiClient;

  WeightRepositoryImpl(this.apiClient);

  @override
  Future<Either<Failure, List<WeightRecord>>> getWeightRecords() async {
    try {
      final response = await apiClient.get(ApiEndpoints.weight);
      final responseData = response.data;

      final List data = (responseData is Map<String, dynamic> && responseData.containsKey('data'))
          ? responseData['data']
          : responseData;

      final items = data.map((json) => WeightRecordDto.fromJson(json).toEntity()).toList();
      return Right(items);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logWeight({
    required String flockId,
    required int sampleSize,
    required double averageWeight,
    required DateTime date,
  }) async {
    try {
      final eventId = const Uuid().v4();
      await apiClient.post(
        '${ApiEndpoints.weight}?flock_id=$flockId', 
        data: {
          'event_id': eventId,
          'sample_size': sampleSize,
          'average_weight_grams': averageWeight,
        }
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

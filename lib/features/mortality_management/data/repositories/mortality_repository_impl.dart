import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/mortality.dart';
import '../../domain/repositories/mortality_repository.dart';
import '../dtos/mortality_dto.dart';

class MortalityRepositoryImpl implements MortalityRepository {
  final Dio apiClient;

  MortalityRepositoryImpl(this.apiClient);

  @override
  Future<Either<Failure, List<Mortality>>> getMortalityRecords() async {
    try {
      final response = await apiClient.get(ApiEndpoints.mortality);
      final responseData = response.data;

      final List data = (responseData is Map<String, dynamic> && responseData.containsKey('data'))
          ? responseData['data']
          : responseData;

      final records = data.map((json) => MortalityDto.fromJson(json).toEntity()).toList();
      return Right(records);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
        }
  }

  @override
  Future<Either<Failure, void>> logMortality({
    required String flockId,
    required int count,
    required String cause,
    required DateTime date,
  }) async {
    try {
      final eventId = const Uuid().v4();
      await apiClient.post(
        '${ApiEndpoints.mortality}?flock_id=$flockId', 
        data: {
          'event_id': eventId,
          'count': count,
          'cause': cause,
        }
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

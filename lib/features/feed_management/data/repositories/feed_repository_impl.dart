import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/feed_record.dart';
import '../../domain/repositories/feed_repository.dart';
import '../dtos/feed_record_dto.dart';

class FeedRepositoryImpl implements FeedRepository {
  final Dio apiClient;

  FeedRepositoryImpl(this.apiClient);

  @override
  Future<Either<Failure, List<FeedRecord>>> getFeedRecords() async {
    try {
      final response = await apiClient.get(ApiEndpoints.feed);
      final responseData = response.data;

      final List data = (responseData is Map<String, dynamic> && responseData.containsKey('data'))
          ? responseData['data']
          : responseData;

      final records = data.map((json) => FeedRecordDto.fromJson(json).toEntity()).toList();
      return Right(records);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logFeed({
    required String flockId,
    required double amount,
    required String feedType,
    required DateTime date,
  }) async {
    try {
      final eventId = const Uuid().v4();
      await apiClient.post(
        '${ApiEndpoints.feed}?flock_id=$flockId', 
        data: {
          'event_id': eventId,
          'feed_type': feedType,
          'quantity_kg': amount, // mapping UI 'amount' to backend 'quantity_kg'
        }
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

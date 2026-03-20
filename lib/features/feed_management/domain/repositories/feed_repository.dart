import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/feed_record.dart';

abstract class FeedRepository {
  Future<Either<Failure, List<FeedRecord>>> getFeedRecords();
  Future<Either<Failure, void>> logFeed({
    required String flockId,
    required double amount,
    required String feedType,
    required DateTime date,
  });
}

import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/usecases/usecase.dart';
import 'package:mobile/features/feed_management/domain/entities/feed_record.dart';
import 'package:mobile/features/feed_management/domain/repositories/feed_repository.dart';

class GetFeedRecordsUseCase implements UseCase<List<FeedRecord>, NoParams> {
  final FeedRepository repository;

  GetFeedRecordsUseCase(this.repository);

  @override
  Future<Either<Failure, List<FeedRecord>>> call(NoParams params) {
    return repository.getFeedRecords();
  }
}

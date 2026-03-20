import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/feed_record.dart';
import '../repositories/feed_repository.dart';

class GetFeedRecordsUseCase implements UseCase<List<FeedRecord>, NoParams> {
  final FeedRepository repository;

  GetFeedRecordsUseCase(this.repository);

  @override
  Future<Either<Failure, List<FeedRecord>>> call(NoParams params) {
    return repository.getFeedRecords();
  }
}

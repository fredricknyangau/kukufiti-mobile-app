import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/weight_record.dart';
import '../repositories/weight_repository.dart';

class GetWeightRecordsUseCase implements UseCase<List<WeightRecord>, NoParams> {
  final WeightRepository repository;

  GetWeightRecordsUseCase(this.repository);

  @override
  Future<Either<Failure, List<WeightRecord>>> call(NoParams params) {
    return repository.getWeightRecords();
  }
}

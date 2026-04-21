import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/usecases/usecase.dart';
import 'package:mobile/features/weight_management/domain/entities/weight_record.dart';
import 'package:mobile/features/weight_management/domain/repositories/weight_repository.dart';

class GetWeightRecordsUseCase implements UseCase<List<WeightRecord>, NoParams> {
  final WeightRepository repository;

  GetWeightRecordsUseCase(this.repository);

  @override
  Future<Either<Failure, List<WeightRecord>>> call(NoParams params) {
    return repository.getWeightRecords();
  }
}

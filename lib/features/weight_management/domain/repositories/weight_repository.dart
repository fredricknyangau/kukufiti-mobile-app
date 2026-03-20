import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/weight_record.dart';

abstract class WeightRepository {
  Future<Either<Failure, List<WeightRecord>>> getWeightRecords();
  Future<Either<Failure, void>> logWeight({
    required String flockId,
    required int sampleSize,
    required double averageWeight,
    required DateTime date,
  });
}

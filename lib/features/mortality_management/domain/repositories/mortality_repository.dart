import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/mortality.dart';

abstract class MortalityRepository {
  Future<Either<Failure, List<Mortality>>> getMortalityRecords();
  Future<Either<Failure, void>> logMortality({
    required String flockId,
    required int count,
    required String cause,
    required DateTime date,
  });
}

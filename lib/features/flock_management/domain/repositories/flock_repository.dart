import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/flock.dart';

abstract class FlockRepository {
  Future<Either<Failure, List<Flock>>> getFlocks();
  Future<Either<Failure, void>> createFlock({required String name, required int batchSize});
  Future<Either<Failure, void>> updateFlock({required int id, required String name, required int batchSize});
  Future<Either<Failure, void>> deleteFlock(int id);
}

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/biosecurity_log.dart';

abstract class BiosecurityRepository {
  Future<Either<Failure, List<BiosecurityLog>>> getLogs();
  Future<Either<Failure, void>> submitChecklist({
    required List<Map<String, dynamic>> items,
    required String completedBy,
    required String notes,
    required DateTime date,
  });
}

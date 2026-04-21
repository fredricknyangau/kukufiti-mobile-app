import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/features/biosecurity_management/domain/entities/biosecurity_log.dart';

abstract class BiosecurityRepository {
  Future<Either<Failure, List<BiosecurityLog>>> getLogs();
  Future<Either<Failure, void>> submitChecklist({
    required List<Map<String, dynamic>> items,
    required String completedBy,
    required String notes,
    required DateTime date,
  });
}

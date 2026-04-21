import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/features/vet_management/domain/entities/vet_consultation.dart';

abstract class VetRepository {
  Future<Either<Failure, List<VetConsultation>>> getConsultations();
  Future<Either<Failure, void>> logConsultation({
    required String reason,
    required String status,
    required DateTime date,
  });
}

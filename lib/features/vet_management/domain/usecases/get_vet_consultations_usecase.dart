import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/usecases/usecase.dart';
import 'package:mobile/features/vet_management/domain/entities/vet_consultation.dart';
import 'package:mobile/features/vet_management/domain/repositories/vet_repository.dart';

class GetVetConsultationsUseCase implements UseCase<List<VetConsultation>, NoParams> {
  final VetRepository repository;

  GetVetConsultationsUseCase(this.repository);

  @override
  Future<Either<Failure, List<VetConsultation>>> call(NoParams params) {
    return repository.getConsultations();
  }
}

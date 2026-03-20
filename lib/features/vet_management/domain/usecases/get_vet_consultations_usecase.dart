import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/vet_consultation.dart';
import '../repositories/vet_repository.dart';

class GetVetConsultationsUseCase implements UseCase<List<VetConsultation>, NoParams> {
  final VetRepository repository;

  GetVetConsultationsUseCase(this.repository);

  @override
  Future<Either<Failure, List<VetConsultation>>> call(NoParams params) {
    return repository.getConsultations();
  }
}

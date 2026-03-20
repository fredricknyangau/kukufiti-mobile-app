import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/person.dart';
import '../repositories/people_repository.dart';

class GetPeopleUseCase implements UseCase<List<Person>, String> {
  final PeopleRepository repository;

  GetPeopleUseCase(this.repository);

  @override
  Future<Either<Failure, List<Person>>> call(String type) {
    return repository.getPeople(type);
  }
}

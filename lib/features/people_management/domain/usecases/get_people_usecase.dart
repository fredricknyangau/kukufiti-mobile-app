import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/usecases/usecase.dart';
import 'package:mobile/features/people_management/domain/entities/person.dart';
import 'package:mobile/features/people_management/domain/repositories/people_repository.dart';

class GetPeopleUseCase implements UseCase<List<Person>, String> {
  final PeopleRepository repository;

  GetPeopleUseCase(this.repository);

  @override
  Future<Either<Failure, List<Person>>> call(String type) {
    return repository.getPeople(type);
  }
}

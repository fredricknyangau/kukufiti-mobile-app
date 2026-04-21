import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/features/people_management/domain/entities/person.dart';

abstract class PeopleRepository {
  Future<Either<Failure, List<Person>>> getPeople(String type);
  Future<Either<Failure, void>> createPerson({
    required String name,
    required String type,
    String? email,
    String? phone,
  });
}

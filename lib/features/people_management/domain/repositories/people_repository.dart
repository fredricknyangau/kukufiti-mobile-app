import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/person.dart';

abstract class PeopleRepository {
  Future<Either<Failure, List<Person>>> getPeople(String type);
  Future<Either<Failure, void>> createPerson({
    required String name,
    required String type,
    String? email,
    String? phone,
  });
}

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/person.dart';
import '../../domain/repositories/people_repository.dart';
import '../dtos/person_dto.dart';

class PeopleRepositoryImpl implements PeopleRepository {
  final Dio apiClient;

  PeopleRepositoryImpl(this.apiClient);

  @override
  Future<Either<Failure, List<Person>>> getPeople(String type) async {
    try {
      final response = await apiClient.get(ApiEndpoints.people(type));
      final responseData = response.data;

      final List data = (responseData is Map<String, dynamic> && responseData.containsKey('data'))
          ? responseData['data']
          : responseData;

      final people = data.map((json) => PersonDto.fromJson(json, type).toEntity()).toList();
      return Right(people);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createPerson({
    required String name,
    required String type,
    String? email,
    String? phone,
  }) async {
    try {
      await apiClient.post(ApiEndpoints.people(type), data: {
        'name': name,
        'type': type,
        'email': ?email,
        'phone': ?phone,
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

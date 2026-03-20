import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/vaccination.dart';
import '../../domain/repositories/vaccination_repository.dart';
import '../dtos/vaccination_dto.dart';

class VaccinationRepositoryImpl implements VaccinationRepository {
  final Dio apiClient;

  VaccinationRepositoryImpl(this.apiClient);

  @override
  Future<Either<Failure, List<Vaccination>>> getVaccinations() async {
    try {
      final response = await apiClient.get(ApiEndpoints.vaccination);
      final responseData = response.data;

      final List data = (responseData is Map<String, dynamic> && responseData.containsKey('data'))
          ? responseData['data']
          : responseData;

      final items = data.map((json) => VaccinationDto.fromJson(json).toEntity()).toList();
      return Right(items);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logVaccination({
    required String flockId,
    required String vaccineName,
    required String diseaseTarget,
    required String method,
    required DateTime date,
  }) async {
    try {
      final eventId = const Uuid().v4();
      await apiClient.post(
        '${ApiEndpoints.vaccination}?flock_id=$flockId', 
        data: {
          'event_id': eventId,
          'vaccine_name': vaccineName,
          'disease_target': diseaseTarget,
          'administration_method': method,
        }
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

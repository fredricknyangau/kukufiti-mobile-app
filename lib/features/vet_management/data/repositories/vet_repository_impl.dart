import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/network/api_endpoints.dart';
import 'package:mobile/features/vet_management/domain/entities/vet_consultation.dart';
import 'package:mobile/features/vet_management/domain/repositories/vet_repository.dart';
import 'package:mobile/features/vet_management/data/dtos/vet_consultation_dto.dart';

class VetRepositoryImpl implements VetRepository {
  final Dio apiClient;

  VetRepositoryImpl(this.apiClient);

  @override
  Future<Either<Failure, List<VetConsultation>>> getConsultations() async {
    try {
      final response = await apiClient.get(ApiEndpoints.vetConsultations);
      final responseData = response.data;

      final List data = (responseData is Map<String, dynamic> && responseData.containsKey('data'))
          ? responseData['data']
          : responseData;

      final items = data.map((json) => VetConsultationDto.fromJson(json).toEntity()).toList();
      return Right(items);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logConsultation({
    required String reason,
    required String status,
    required DateTime date,
  }) async {
    try {
      await apiClient.post(ApiEndpoints.vetConsultations, data: {
        'reason': reason,
        'status': status,
        'date': date.toIso8601String(),
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/network/api_endpoints.dart';
import 'package:mobile/features/sales_management/domain/entities/sale.dart';
import 'package:mobile/features/sales_management/domain/repositories/sales_repository.dart';
import 'package:mobile/features/sales_management/data/dtos/sale_dto.dart';

class SalesRepositoryImpl implements SalesRepository {
  final Dio apiClient;

  SalesRepositoryImpl(this.apiClient);

  @override
  Future<Either<Failure, List<Sale>>> getSales() async {
    try {
      final response = await apiClient.get(ApiEndpoints.sales);
      final responseData = response.data;

      final List data = (responseData is Map<String, dynamic> && responseData.containsKey('data'))
          ? responseData['data']
          : responseData;

      final sales = data.map((json) => SaleDto.fromJson(json).toEntity()).toList();
      return Right(sales);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createSale({
    required String flockId,
    required double pricePerBird,
    required double amount,
    required int quantity,
    required String buyer,
    required DateTime date,
  }) async {
    try {
      await apiClient.post(ApiEndpoints.sales, data: {
        'flock_id': flockId,
        'quantity': quantity,
        'price_per_bird': pricePerBird,
        'total_amount': amount, // amount is total
        'buyer_name': buyer,
        'date': date.toIso8601String().split('T')[0], // yyyy-mm-dd
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

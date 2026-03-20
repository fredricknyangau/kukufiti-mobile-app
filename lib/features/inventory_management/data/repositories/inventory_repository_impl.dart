import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../dtos/inventory_item_dto.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final Dio apiClient;

  InventoryRepositoryImpl(this.apiClient);

  @override
  Future<Either<Failure, List<InventoryItem>>> getInventoryItems() async {
    try {
      final response = await apiClient.get(ApiEndpoints.inventory);
      final responseData = response.data;

      final List data = (responseData is Map<String, dynamic> && responseData.containsKey('data'))
          ? responseData['data']
          : responseData;

      final items = data.map((json) => InventoryItemDto.fromJson(json).toEntity()).toList();
      return Right(items);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addInventoryItem({
    required String name,
    required String category,
    required double quantity,
    required String unit,
    required double minimumStock,
    required double costPerUnit,
  }) async {
    try {
      await apiClient.post(ApiEndpoints.inventory, data: {
        'name': name,
        'category': category,
        'quantity': quantity,
        'unit': unit,
        'minimum_stock': minimumStock,
        'cost_per_unit': costPerUnit,
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

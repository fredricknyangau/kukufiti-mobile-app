import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/features/inventory_management/domain/entities/inventory_item.dart';

abstract class InventoryRepository {
  Future<Either<Failure, List<InventoryItem>>> getInventoryItems();
  Future<Either<Failure, void>> addInventoryItem({
    required String name,
    required String category,
    required double quantity,
    required String unit,
    required double minimumStock,
    required double costPerUnit,
  });
}

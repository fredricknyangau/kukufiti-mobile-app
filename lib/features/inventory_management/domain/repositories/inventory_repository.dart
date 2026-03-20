import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/inventory_item.dart';

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

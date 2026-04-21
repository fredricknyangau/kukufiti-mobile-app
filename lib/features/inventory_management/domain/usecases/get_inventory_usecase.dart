import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/usecases/usecase.dart';
import 'package:mobile/features/inventory_management/domain/entities/inventory_item.dart';
import 'package:mobile/features/inventory_management/domain/repositories/inventory_repository.dart';

class GetInventoryUseCase implements UseCase<List<InventoryItem>, NoParams> {
  final InventoryRepository repository;

  GetInventoryUseCase(this.repository);

  @override
  Future<Either<Failure, List<InventoryItem>>> call(NoParams params) {
    return repository.getInventoryItems();
  }
}

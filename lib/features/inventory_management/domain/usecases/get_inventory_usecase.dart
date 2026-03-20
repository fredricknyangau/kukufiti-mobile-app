import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/inventory_item.dart';
import '../repositories/inventory_repository.dart';

class GetInventoryUseCase implements UseCase<List<InventoryItem>, NoParams> {
  final InventoryRepository repository;

  GetInventoryUseCase(this.repository);

  @override
  Future<Either<Failure, List<InventoryItem>>> call(NoParams params) {
    return repository.getInventoryItems();
  }
}

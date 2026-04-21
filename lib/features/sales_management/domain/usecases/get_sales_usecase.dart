import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/usecases/usecase.dart';
import 'package:mobile/features/sales_management/domain/entities/sale.dart';
import 'package:mobile/features/sales_management/domain/repositories/sales_repository.dart';

class GetSalesUseCase implements UseCase<List<Sale>, NoParams> {
  final SalesRepository repository;

  GetSalesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Sale>>> call(NoParams params) {
    return repository.getSales();
  }
}

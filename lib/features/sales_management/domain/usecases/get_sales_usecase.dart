import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/sale.dart';
import '../repositories/sales_repository.dart';

class GetSalesUseCase implements UseCase<List<Sale>, NoParams> {
  final SalesRepository repository;

  GetSalesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Sale>>> call(NoParams params) {
    return repository.getSales();
  }
}

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/sale.dart';

abstract class SalesRepository {
  Future<Either<Failure, List<Sale>>> getSales();
  Future<Either<Failure, void>> createSale({
    required String flockId,
    required double pricePerBird,
    required double amount,
    required int quantity,
    required String buyer,
    required DateTime date,
  });
}

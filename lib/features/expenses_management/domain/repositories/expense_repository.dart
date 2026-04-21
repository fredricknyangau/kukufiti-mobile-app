import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/features/expenses_management/domain/entities/expense.dart';

abstract class ExpenseRepository {
  Future<Either<Failure, List<Expense>>> getExpenses();
  Future<Either<Failure, void>> createExpense({
    required double amount,
    required String category,
    required String description,
    required DateTime date,
    String? flockId,
    double? quantity,
    String? unit,
  });
}

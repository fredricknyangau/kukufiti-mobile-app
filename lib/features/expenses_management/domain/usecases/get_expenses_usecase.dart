import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/usecases/usecase.dart';
import 'package:mobile/features/expenses_management/domain/entities/expense.dart';
import 'package:mobile/features/expenses_management/domain/repositories/expense_repository.dart';

class GetExpensesUseCase implements UseCase<List<Expense>, NoParams> {
  final ExpenseRepository repository;

  GetExpensesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Expense>>> call(NoParams params) {
    return repository.getExpenses();
  }
}

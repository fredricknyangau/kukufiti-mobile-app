import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client_provider.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/repositories/expense_repository_impl.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../domain/usecases/get_expenses_usecase.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ExpenseRepositoryImpl(apiClient);
});

final getExpensesUseCaseProvider = Provider<GetExpensesUseCase>((ref) {
  final repository = ref.watch(expenseRepositoryProvider);
  return GetExpensesUseCase(repository);
});

class ExpenseNotifier extends AsyncNotifier<List<Expense>> {
  @override
  FutureOr<List<Expense>> build() async {
    final useCase = ref.watch(getExpensesUseCaseProvider);
    final result = await useCase(const NoParams());
    return result.fold(
      (failure) => throw failure.message,
      (expenses) => expenses,
    );
  }

  Future<void> reload() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(getExpensesUseCaseProvider);
      final result = await useCase(const NoParams());
      return result.fold(
        (failure) => throw failure.message,
        (expenses) => expenses,
      );
    });
  }

  Future<void> create({
    required double amount,
    required String category,
    required String description,
    required DateTime date,
    String? flockId,
    double? quantity,
    String? unit,
  }) async {
    state = const AsyncValue.loading();
    final repo = ref.read(expenseRepositoryProvider);
    final result = await repo.createExpense(
      amount: amount,
      category: category,
      description: description,
      date: date,
      flockId: flockId,
      quantity: quantity,
      unit: unit,
    );

    result.fold(
      (f) => state = AsyncValue.error(f.message, StackTrace.current),
      (_) => reload(),
    );
  }
}

final expensesProvider = AsyncNotifierProvider<ExpenseNotifier, List<Expense>>(() {
  return ExpenseNotifier();
});

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../dtos/expense_dto.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final Dio apiClient;

  ExpenseRepositoryImpl(this.apiClient);

  @override
  Future<Either<Failure, List<Expense>>> getExpenses() async {
    try {
      final response = await apiClient.get(ApiEndpoints.expenditures);
      final responseData = response.data;

      final List data = (responseData is Map<String, dynamic> && responseData.containsKey('data'))
          ? responseData['data']
          : responseData;

      final expenses = data.map((json) => ExpenseDto.fromJson(json).toEntity()).toList();
      return Right(expenses);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createExpense({
    required double amount,
    required String category,
    required String description,
    required DateTime date,
    String? flockId,
    double? quantity,
    String? unit,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'amount': amount,
        'category': category,
        'description': description,
        'date': date.toIso8601String().split('T')[0],
      };

      if (flockId != null) data['flock_id'] = flockId;
      if (quantity != null) data['quantity'] = quantity;
      if (unit != null) data['unit'] = unit;

      await apiClient.post(ApiEndpoints.expenditures, data: data);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

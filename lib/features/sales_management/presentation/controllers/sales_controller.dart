import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/api_client_provider.dart';
import 'package:mobile/core/usecases/usecase.dart';
import 'package:mobile/features/sales_management/data/repositories/sales_repository_impl.dart';
import 'package:mobile/features/sales_management/domain/entities/sale.dart';
import 'package:mobile/features/sales_management/domain/repositories/sales_repository.dart';
import 'package:mobile/features/sales_management/domain/usecases/get_sales_usecase.dart';

final salesRepositoryProvider = Provider<SalesRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SalesRepositoryImpl(apiClient);
});

final getSalesUseCaseProvider = Provider<GetSalesUseCase>((ref) {
  final repository = ref.watch(salesRepositoryProvider);
  return GetSalesUseCase(repository);
});

class SalesNotifier extends AsyncNotifier<List<Sale>> {
  @override
  FutureOr<List<Sale>> build() async {
    final useCase = ref.watch(getSalesUseCaseProvider);
    final result = await useCase(const NoParams());
    return result.fold(
      (failure) => throw failure.message,
      (sales) => sales,
    );
  }

  Future<void> reload() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(getSalesUseCaseProvider);
      final result = await useCase(const NoParams());
      return result.fold(
        (failure) => throw failure.message,
        (sales) => sales,
      );
    });
  }

  Future<void> create({
    required String flockId,
    required double pricePerBird,
    required double amount,
    required int quantity,
    required String buyer,
    required DateTime date,
  }) async {
    state = const AsyncValue.loading();
    final repo = ref.read(salesRepositoryProvider);
    final result = await repo.createSale(
      flockId: flockId,
      pricePerBird: pricePerBird,
      amount: amount,
      quantity: quantity,
      buyer: buyer,
      date: date,
    );

    result.fold(
      (f) => state = AsyncValue.error(f.message, StackTrace.current),
      (_) => reload(),
    );
  }
}

final salesProvider = AsyncNotifierProvider<SalesNotifier, List<Sale>>(() {
  return SalesNotifier();
});

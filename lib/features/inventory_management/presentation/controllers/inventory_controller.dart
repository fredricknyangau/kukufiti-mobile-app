import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/api_client_provider.dart';
import 'package:mobile/core/usecases/usecase.dart';
import 'package:mobile/features/inventory_management/data/repositories/inventory_repository_impl.dart';
import 'package:mobile/features/inventory_management/domain/entities/inventory_item.dart';
import 'package:mobile/features/inventory_management/domain/repositories/inventory_repository.dart';
import 'package:mobile/features/inventory_management/domain/usecases/get_inventory_usecase.dart';

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return InventoryRepositoryImpl(apiClient);
});

final getInventoryUseCaseProvider = Provider<GetInventoryUseCase>((ref) {
  final repository = ref.watch(inventoryRepositoryProvider);
  return GetInventoryUseCase(repository);
});

class InventoryNotifier extends AsyncNotifier<List<InventoryItem>> {
  @override
  FutureOr<List<InventoryItem>> build() async {
    final useCase = ref.watch(getInventoryUseCaseProvider);
    final result = await useCase(const NoParams());
    return result.fold(
      (failure) => throw failure.message,
      (items) => items,
    );
  }

  Future<void> reload() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(getInventoryUseCaseProvider);
      final result = await useCase(const NoParams());
      return result.fold(
        (failure) => throw failure.message,
        (items) => items,
      );
    });
  }

  Future<void> add({
    required String name,
    required String category,
    required double quantity,
    required String unit,
    required double minimumStock,
    required double costPerUnit,
  }) async {
    state = const AsyncValue.loading();
    final repo = ref.read(inventoryRepositoryProvider);
    final result = await repo.addInventoryItem(
      name: name,
      category: category,
      quantity: quantity,
      unit: unit,
      minimumStock: minimumStock,
      costPerUnit: costPerUnit,
    );

    result.fold(
      (f) => state = AsyncValue.error(f.message, StackTrace.current),
      (_) => reload(),
    );
  }
}

final inventoryProvider = AsyncNotifierProvider<InventoryNotifier, List<InventoryItem>>(() {
  return InventoryNotifier();
});

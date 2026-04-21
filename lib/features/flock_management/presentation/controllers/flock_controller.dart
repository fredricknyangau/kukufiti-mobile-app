import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/api_client_provider.dart';
import 'package:mobile/core/usecases/usecase.dart';
import 'package:mobile/features/flock_management/data/repositories/flock_repository_impl.dart';
import 'package:mobile/features/flock_management/domain/entities/flock.dart';
import 'package:mobile/features/flock_management/domain/repositories/flock_repository.dart';
import 'package:mobile/features/flock_management/domain/usecases/get_flocks_usecase.dart';

final flockRepositoryProvider = Provider<FlockRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return FlockRepositoryImpl(apiClient);
});

final getFlocksUseCaseProvider = Provider<GetFlocksUseCase>((ref) {
  final repository = ref.watch(flockRepositoryProvider);
  return GetFlocksUseCase(repository);
});

class FlockNotifier extends AsyncNotifier<List<Flock>> {
  @override
  Future<List<Flock>> build() async {
    final useCase = ref.watch(getFlocksUseCaseProvider);
    final result = await useCase(const NoParams());
    return result.fold(
      (failure) => throw failure.message,
      (flocks) => flocks,
    );
  }

  Future<void> reload() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(getFlocksUseCaseProvider);
      final result = await useCase(const NoParams());
      return result.fold(
        (failure) => throw failure.message,
        (flocks) => flocks,
      );
    });
  }

  Future<void> create({required String name, required int batchSize}) async {
    state = const AsyncValue.loading();
    final repo = ref.read(flockRepositoryProvider);
    final result = await repo.createFlock(name: name, batchSize: batchSize);
    
    result.fold(
      (f) => state = AsyncValue.error(f.message, StackTrace.current),
      (_) => reload(),
    );
  }

  Future<void> updateFlock({required int id, required String name, required int batchSize}) async {
    state = const AsyncValue.loading();
    final repo = ref.read(flockRepositoryProvider);
    final result = await repo.updateFlock(id: id, name: name, batchSize: batchSize);

    result.fold(
      (f) => state = AsyncValue.error(f.message, StackTrace.current),
      (_) => reload(),
    );
  }

  Future<void> delete(int id) async {
    state = const AsyncValue.loading();
    final repo = ref.read(flockRepositoryProvider);
    final result = await repo.deleteFlock(id);

    result.fold(
      (f) => state = AsyncValue.error(f.message, StackTrace.current),
      (_) => reload(),
    );
  }
}

final flockProvider = AsyncNotifierProvider<FlockNotifier, List<Flock>>(() {
  return FlockNotifier();
});

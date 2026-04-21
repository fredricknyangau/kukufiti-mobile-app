import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/api_client_provider.dart';
import 'package:mobile/core/usecases/usecase.dart';
import 'package:mobile/features/mortality_management/data/repositories/mortality_repository_impl.dart';
import 'package:mobile/features/mortality_management/domain/entities/mortality.dart';
import 'package:mobile/features/mortality_management/domain/repositories/mortality_repository.dart';
import 'package:mobile/features/mortality_management/domain/usecases/get_mortality_usecase.dart';

final mortalityRepositoryProvider = Provider<MortalityRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MortalityRepositoryImpl(apiClient);
});

final getMortalityUseCaseProvider = Provider<GetMortalityUseCase>((ref) {
  final repository = ref.watch(mortalityRepositoryProvider);
  return GetMortalityUseCase(repository);
});

class MortalityNotifier extends AsyncNotifier<List<Mortality>> {
  @override
  FutureOr<List<Mortality>> build() async {
    final useCase = ref.watch(getMortalityUseCaseProvider);
    final result = await useCase(const NoParams());
    return result.fold(
      (failure) => throw failure.message,
      (records) => records,
    );
  }

  Future<void> reload() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(getMortalityUseCaseProvider);
      final result = await useCase(const NoParams());
      return result.fold(
        (failure) => throw failure.message,
        (records) => records,
      );
    });
  }

  Future<void> log({
    required String flockId,
    required int count,
    required String cause,
    required DateTime date,
  }) async {
    state = const AsyncValue.loading();
    final repo = ref.read(mortalityRepositoryProvider);
    final result = await repo.logMortality(
      flockId: flockId,
      count: count,
      cause: cause,
      date: date,
    );

    result.fold(
      (f) => state = AsyncValue.error(f.message, StackTrace.current),
      (_) => reload(),
    );
  }
}

final mortalityProvider = AsyncNotifierProvider<MortalityNotifier, List<Mortality>>(() {
  return MortalityNotifier();
});

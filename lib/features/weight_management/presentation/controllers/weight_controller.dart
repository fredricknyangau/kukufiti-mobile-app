import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/api_client_provider.dart';
import 'package:mobile/core/usecases/usecase.dart';
import 'package:mobile/features/weight_management/data/repositories/weight_repository_impl.dart';
import 'package:mobile/features/weight_management/domain/entities/weight_record.dart';
import 'package:mobile/features/weight_management/domain/repositories/weight_repository.dart';
import 'package:mobile/features/weight_management/domain/usecases/get_weight_records_usecase.dart';

final weightRepositoryProvider = Provider<WeightRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return WeightRepositoryImpl(apiClient);
});

final getWeightRecordsUseCaseProvider = Provider<GetWeightRecordsUseCase>((ref) {
  final repository = ref.watch(weightRepositoryProvider);
  return GetWeightRecordsUseCase(repository);
});

class WeightNotifier extends AsyncNotifier<List<WeightRecord>> {
  @override
  FutureOr<List<WeightRecord>> build() async {
    final useCase = ref.watch(getWeightRecordsUseCaseProvider);
    final result = await useCase(const NoParams());
    return result.fold(
      (failure) => throw failure.message,
      (items) => items,
    );
  }

  Future<void> reload() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(getWeightRecordsUseCaseProvider);
      final result = await useCase(const NoParams());
      return result.fold(
        (failure) => throw failure.message,
        (items) => items,
      );
    });
  }

  Future<void> log({
    required String flockId,
    required int sampleSize,
    required double averageWeight,
    required DateTime date,
  }) async {
    state = const AsyncValue.loading();
    final repo = ref.read(weightRepositoryProvider);
    final result = await repo.logWeight(
      flockId: flockId,
      sampleSize: sampleSize,
      averageWeight: averageWeight,
      date: date,
    );

    result.fold(
      (f) => state = AsyncValue.error(f.message, StackTrace.current),
      (_) => reload(),
    );
  }
}

final weightProvider = AsyncNotifierProvider<WeightNotifier, List<WeightRecord>>(() {
  return WeightNotifier();
});

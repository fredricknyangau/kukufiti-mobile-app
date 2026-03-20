import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client_provider.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/repositories/biosecurity_repository_impl.dart';
import '../../domain/entities/biosecurity_log.dart';
import '../../domain/repositories/biosecurity_repository.dart';
import '../../domain/usecases/get_biosecurity_logs_usecase.dart';

final biosecurityRepositoryProvider = Provider<BiosecurityRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return BiosecurityRepositoryImpl(apiClient);
});

final getBiosecurityLogsUseCaseProvider = Provider<GetBiosecurityLogsUseCase>((ref) {
  final repository = ref.watch(biosecurityRepositoryProvider);
  return GetBiosecurityLogsUseCase(repository);
});

class BiosecurityNotifier extends AsyncNotifier<List<BiosecurityLog>> {
  @override
  FutureOr<List<BiosecurityLog>> build() async {
    final useCase = ref.watch(getBiosecurityLogsUseCaseProvider);
    final result = await useCase(const NoParams());
    return result.fold(
      (failure) => throw failure.message,
      (items) => items,
    );
  }

  Future<void> reload() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(getBiosecurityLogsUseCaseProvider);
      final result = await useCase(const NoParams());
      return result.fold(
        (failure) => throw failure.message,
        (items) => items,
      );
    });
  }

  Future<void> submit({
    required List<Map<String, dynamic>> items,
    required String completedBy,
    required String notes,
    required DateTime date,
  }) async {
    state = const AsyncValue.loading();
    final repo = ref.read(biosecurityRepositoryProvider);
    final result = await repo.submitChecklist(
      items: items,
      completedBy: completedBy,
      notes: notes,
      date: date,
    );

    result.fold(
      (f) => state = AsyncValue.error(f.message, StackTrace.current),
      (_) => reload(),
    );
  }
}

final biosecurityLogsProvider = AsyncNotifierProvider<BiosecurityNotifier, List<BiosecurityLog>>(() {
  return BiosecurityNotifier();
});

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client_provider.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/repositories/vet_repository_impl.dart';
import '../../domain/entities/vet_consultation.dart';
import '../../domain/repositories/vet_repository.dart';
import '../../domain/usecases/get_vet_consultations_usecase.dart';

final vetRepositoryProvider = Provider<VetRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return VetRepositoryImpl(apiClient);
});

final getVetConsultationsUseCaseProvider = Provider<GetVetConsultationsUseCase>((ref) {
  final repository = ref.watch(vetRepositoryProvider);
  return GetVetConsultationsUseCase(repository);
});

class VetNotifier extends AsyncNotifier<List<VetConsultation>> {
  @override
  FutureOr<List<VetConsultation>> build() async {
    final useCase = ref.watch(getVetConsultationsUseCaseProvider);
    final result = await useCase(const NoParams());
    return result.fold(
      (failure) => throw failure.message,
      (items) => items,
    );
  }

  Future<void> reload() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(getVetConsultationsUseCaseProvider);
      final result = await useCase(const NoParams());
      return result.fold(
        (failure) => throw failure.message,
        (items) => items,
      );
    });
  }

  Future<void> log({
    required String reason,
    required String status,
    required DateTime date,
  }) async {
    state = const AsyncValue.loading();
    final repo = ref.read(vetRepositoryProvider);
    final result = await repo.logConsultation(
      reason: reason,
      status: status,
      date: date,
    );

    result.fold(
      (f) => state = AsyncValue.error(f.message, StackTrace.current),
      (_) => reload(),
    );
  }
}

final vetConsultationsProvider = AsyncNotifierProvider<VetNotifier, List<VetConsultation>>(() {
  return VetNotifier();
});

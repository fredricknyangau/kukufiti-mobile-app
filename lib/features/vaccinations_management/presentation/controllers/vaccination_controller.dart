import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/api_client_provider.dart';
import 'package:mobile/core/usecases/usecase.dart';
import 'package:mobile/features/vaccinations_management/data/repositories/vaccination_repository_impl.dart';
import 'package:mobile/features/vaccinations_management/domain/entities/vaccination.dart';
import 'package:mobile/features/vaccinations_management/domain/repositories/vaccination_repository.dart';
import 'package:mobile/features/vaccinations_management/domain/usecases/get_vaccinations_usecase.dart';

final vaccinationRepositoryProvider = Provider<VaccinationRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return VaccinationRepositoryImpl(apiClient);
});

final getVaccinationsUseCaseProvider = Provider<GetVaccinationsUseCase>((ref) {
  final repository = ref.watch(vaccinationRepositoryProvider);
  return GetVaccinationsUseCase(repository);
});

class VaccinationNotifier extends AsyncNotifier<List<Vaccination>> {
  @override
  FutureOr<List<Vaccination>> build() async {
    final useCase = ref.watch(getVaccinationsUseCaseProvider);
    final result = await useCase(const NoParams());
    return result.fold(
      (failure) => throw failure.message,
      (items) => items,
    );
  }

  Future<void> reload() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(getVaccinationsUseCaseProvider);
      final result = await useCase(const NoParams());
      return result.fold(
        (failure) => throw failure.message,
        (items) => items,
      );
    });
  }

  Future<void> log({
    required String flockId,
    required String vaccineName,
    required String diseaseTarget,
    required String method,
    required DateTime date,
  }) async {
    state = const AsyncValue.loading();
    final repo = ref.read(vaccinationRepositoryProvider);
    final result = await repo.logVaccination(
      flockId: flockId,
      vaccineName: vaccineName,
      diseaseTarget: diseaseTarget,
      method: method,
      date: date,
    );

    result.fold(
      (f) => state = AsyncValue.error(f.message, StackTrace.current),
      (_) => reload(),
    );
  }
}

final vaccinationProvider = AsyncNotifierProvider<VaccinationNotifier, List<Vaccination>>(() {
  return VaccinationNotifier();
});

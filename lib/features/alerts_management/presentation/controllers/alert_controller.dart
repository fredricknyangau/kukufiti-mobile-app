import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client_provider.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/repositories/alert_repository_impl.dart';
import '../../domain/entities/alert.dart';
import '../../domain/repositories/alert_repository.dart';
import '../../domain/usecases/get_alerts_usecase.dart';

final alertRepositoryProvider = Provider<AlertRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AlertRepositoryImpl(apiClient);
});

final getAlertsUseCaseProvider = Provider<GetAlertsUseCase>((ref) {
  final repository = ref.watch(alertRepositoryProvider);
  return GetAlertsUseCase(repository);
});

class AlertNotifier extends AsyncNotifier<List<Alert>> {
  @override
  FutureOr<List<Alert>> build() async {
    final useCase = ref.watch(getAlertsUseCaseProvider);
    final result = await useCase(const NoParams());
    return result.fold(
      (failure) => throw failure.message,
      (items) => items,
    );
  }

  Future<void> reload() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(getAlertsUseCaseProvider);
      final result = await useCase(const NoParams());
      return result.fold(
        (failure) => throw failure.message,
        (items) => items,
      );
    });
  }
}

final alertsProvider = AsyncNotifierProvider<AlertNotifier, List<Alert>>(() {
  return AlertNotifier();
});

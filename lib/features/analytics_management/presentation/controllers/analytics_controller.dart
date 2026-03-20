import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client_provider.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/repositories/analytics_repository_impl.dart';
import '../../domain/entities/analytics_metrics.dart';
import '../../domain/entities/finance_spot.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../../domain/usecases/get_analytics_metrics_usecase.dart';
import '../../domain/usecases/get_finance_spots_usecase.dart';

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AnalyticsRepositoryImpl(apiClient);
});

final getAnalyticsMetricsUseCaseProvider = Provider<GetAnalyticsMetricsUseCase>((ref) {
  final repository = ref.watch(analyticsRepositoryProvider);
  return GetAnalyticsMetricsUseCase(repository);
});

final getFinanceSpotsUseCaseProvider = Provider<GetFinanceSpotsUseCase>((ref) {
  final repository = ref.watch(analyticsRepositoryProvider);
  return GetFinanceSpotsUseCase(repository);
});

class AnalyticsMetricsNotifier extends AsyncNotifier<AnalyticsMetrics> {
  @override
  FutureOr<AnalyticsMetrics> build() async {
    final useCase = ref.watch(getAnalyticsMetricsUseCaseProvider);
    final result = await useCase(const NoParams());
    return result.fold(
      (failure) => throw failure.message,
      (metrics) => metrics,
    );
  }

  Future<void> reload() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(getAnalyticsMetricsUseCaseProvider);
      final result = await useCase(const NoParams());
      return result.fold(
        (failure) => throw failure.message,
        (metrics) => metrics,
      );
    });
  }
}

class FinanceChartDataNotifier extends AsyncNotifier<List<FinanceSpot>> {
  @override
  FutureOr<List<FinanceSpot>> build() async {
    final useCase = ref.watch(getFinanceSpotsUseCaseProvider);
    final result = await useCase(const NoParams());
    return result.fold(
      (failure) => throw failure.message,
      (spots) => spots,
    );
  }

  Future<void> reload() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(getFinanceSpotsUseCaseProvider);
      final result = await useCase(const NoParams());
      return result.fold(
        (failure) => throw failure.message,
        (spots) => spots,
      );
    });
  }
}

final analyticsMetricsProvider = AsyncNotifierProvider<AnalyticsMetricsNotifier, AnalyticsMetrics>(() {
  return AnalyticsMetricsNotifier();
});

final financeChartDataProvider = AsyncNotifierProvider<FinanceChartDataNotifier, List<FinanceSpot>>(() {
  return FinanceChartDataNotifier();
});

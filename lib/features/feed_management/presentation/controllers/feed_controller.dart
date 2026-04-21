import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/api_client_provider.dart';
import 'package:mobile/core/usecases/usecase.dart';
import 'package:mobile/features/feed_management/data/repositories/feed_repository_impl.dart';
import 'package:mobile/features/feed_management/domain/entities/feed_record.dart';
import 'package:mobile/features/feed_management/domain/repositories/feed_repository.dart';
import 'package:mobile/features/feed_management/domain/usecases/get_feed_records_usecase.dart';

final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return FeedRepositoryImpl(apiClient);
});

final getFeedRecordsUseCaseProvider = Provider<GetFeedRecordsUseCase>((ref) {
  final repository = ref.watch(feedRepositoryProvider);
  return GetFeedRecordsUseCase(repository);
});

class FeedNotifier extends AsyncNotifier<List<FeedRecord>> {
  @override
  FutureOr<List<FeedRecord>> build() async {
    final useCase = ref.watch(getFeedRecordsUseCaseProvider);
    final result = await useCase(const NoParams());
    return result.fold(
      (failure) => throw failure.message,
      (records) => records,
    );
  }

  Future<void> reload() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(getFeedRecordsUseCaseProvider);
      final result = await useCase(const NoParams());
      return result.fold(
        (failure) => throw failure.message,
        (records) => records,
      );
    });
  }

  Future<void> log({
    required String flockId,
    required double amount,
    required String feedType,
    required DateTime date,
  }) async {
    state = const AsyncValue.loading();
    final repo = ref.read(feedRepositoryProvider);
    final result = await repo.logFeed(
      flockId: flockId,
      amount: amount,
      feedType: feedType,
      date: date,
    );

    result.fold(
      (f) => state = AsyncValue.error(f.message, StackTrace.current),
      (_) => reload(),
    );
  }
}

final feedProvider = AsyncNotifierProvider<FeedNotifier, List<FeedRecord>>(() {
  return FeedNotifier();
});

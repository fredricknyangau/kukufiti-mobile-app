import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';

class BroilerState {
  final Map<String, dynamic>? currentBatch;
  final List<dynamic> batches;
  final bool isLoading;
  final String? error;

  const BroilerState({
    this.currentBatch,
    this.batches = const [],
    this.isLoading = false,
    this.error,
  });

  BroilerState copyWith({
    Map<String, dynamic>? currentBatch,
    List<dynamic>? batches,
    bool? isLoading,
    String? error,
  }) {
    return BroilerState(
      currentBatch: currentBatch ?? this.currentBatch,
      batches: batches ?? this.batches,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class BroilerNotifier extends Notifier<BroilerState> {
  @override
  BroilerState build() {
    // Schedule the fetch to happen after the first build is complete
    Future.microtask(() => fetchBatches());
    return const BroilerState(isLoading: true);
  }

  Future<void> fetchBatches() async {
    // We can now safely access 'state'
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await ApiClient.instance.get(ApiEndpoints.batches);
      final responseData = response.data;

      final List data = (responseData is Map<String, dynamic> && responseData.containsKey('data'))
          ? responseData['data']
          : responseData;
      
      state = state.copyWith(
        batches: data,
        currentBatch: data.isNotEmpty ? data.first : null,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void selectBatch(Map<String, dynamic> batch) {
    state = state.copyWith(currentBatch: batch);
  }
}

final broilerProvider = NotifierProvider<BroilerNotifier, BroilerState>(BroilerNotifier.new);

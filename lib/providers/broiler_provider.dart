import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../core/models/broiler_models.dart';

class BroilerState {
  final Batch? currentBatch;
  final List<Batch> batches;
  final bool isLoading;
  final String? error;

  const BroilerState({
    this.currentBatch,
    this.batches = const [],
    this.isLoading = false,
    this.error,
  });

  BroilerState copyWith({
    Batch? currentBatch,
    List<Batch>? batches,
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
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await ApiClient.instance.get(ApiEndpoints.batches);
      final responseData = response.data;

      final List data = (responseData is Map<String, dynamic> && responseData.containsKey('data'))
          ? responseData['data']
          : responseData;
      
      final batches = data.map((e) {
        // Handle mapping from snake_case API to camelCase model if necessary,
        // or ensure @JsonKey is used in the model.
        // Assuming the model.fromJson handles it.
        return Batch.fromJson(e as Map<String, dynamic>);
      }).toList();

      state = state.copyWith(
        batches: batches,
        currentBatch: batches.isNotEmpty ? batches.first : null,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void selectBatch(Batch batch) {
    state = state.copyWith(currentBatch: batch);
  }
}

final broilerProvider = NotifierProvider<BroilerNotifier, BroilerState>(BroilerNotifier.new);

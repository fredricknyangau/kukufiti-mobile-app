import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/feed_recommendation.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';

class AiInsightsState {
  final bool isLoading;
  final String? error;
  final FeedRecommendationResponse? recommendation;

  AiInsightsState({
    this.isLoading = false,
    this.error,
    this.recommendation,
  });

  AiInsightsState copyWith({
    bool? isLoading,
    String? error,
    FeedRecommendationResponse? recommendation,
  }) {
    return AiInsightsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      recommendation: recommendation ?? this.recommendation,
    );
  }
}

class AiInsightsNotifier extends Notifier<AiInsightsState> {
  @override
  AiInsightsState build() {
    return AiInsightsState();
  }

  Future<void> fetchFeedRecommendation(FeedRecommendationRequest request) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await ApiClient.instance.post(
        ApiEndpoints.aiFeedRecommendation,
        data: request.toJson(),
      );
      
      final data = response.data is Map<String, dynamic> && response.data.containsKey('data')
          ? response.data['data']
          : response.data;

      state = state.copyWith(
        isLoading: false,
        recommendation: FeedRecommendationResponse.fromJson(data),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearRecommendation() {
    state = AiInsightsState();
  }
}

final aiInsightsProvider = NotifierProvider<AiInsightsNotifier, AiInsightsState>(
  AiInsightsNotifier.new,
);


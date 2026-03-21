import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/feed_recommendation.dart';
import '../../data/models/mortality_analysis.dart';
import '../../data/models/harvest_prediction.dart';
import '../../data/models/disease_risk.dart';
import '../../data/models/fcr_insights.dart';
import '../../data/models/ai_chat.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';

class AiInsightsState {
  final bool isLoading;
  final String? error;
  final FeedRecommendationResponse? recommendation;
  final MortalityAnalysisResponse? mortalityAnalysis;
  final HarvestPredictionResponse? harvestPrediction;
  final DiseaseRiskResponse? diseaseRisk;
  final FcrInsightsResponse? fcrInsights;
  final List<ChatMessage> chatHistory;

  AiInsightsState({
    this.isLoading = false,
    this.error,
    this.recommendation,
    this.mortalityAnalysis,
    this.harvestPrediction,
    this.diseaseRisk,
    this.fcrInsights,
    this.chatHistory = const [],
  });

  AiInsightsState copyWith({
    bool? isLoading,
    String? error,
    FeedRecommendationResponse? recommendation,
    MortalityAnalysisResponse? mortalityAnalysis,
    HarvestPredictionResponse? harvestPrediction,
    DiseaseRiskResponse? diseaseRisk,
    FcrInsightsResponse? fcrInsights,
    List<ChatMessage>? chatHistory,
  }) {
    return AiInsightsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      recommendation: recommendation ?? this.recommendation,
      mortalityAnalysis: mortalityAnalysis ?? this.mortalityAnalysis,
      harvestPrediction: harvestPrediction ?? this.harvestPrediction,
      diseaseRisk: diseaseRisk ?? this.diseaseRisk,
      fcrInsights: fcrInsights ?? this.fcrInsights,
      chatHistory: chatHistory ?? this.chatHistory,
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
      final data = _extractData(response);
      state = state.copyWith(isLoading: false, recommendation: FeedRecommendationResponse.fromJson(data));
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchMortalityAnalysis(MortalityAnalysisRequest request) async {
    state = state.copyWith(isLoading: true, error: null, mortalityAnalysis: null);
    try {
      final response = await ApiClient.instance.post(
        ApiEndpoints.aiMortalityAnalysis,
        data: request.toJson(),
      );
      final data = _extractData(response);
      state = state.copyWith(isLoading: false, mortalityAnalysis: MortalityAnalysisResponse.fromJson(data));
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchHarvestPrediction(HarvestPredictionRequest request) async {
    state = state.copyWith(isLoading: true, error: null, harvestPrediction: null);
    try {
      final response = await ApiClient.instance.post(
        ApiEndpoints.aiHarvestPrediction,
        data: request.toJson(),
      );
      final data = _extractData(response);
      state = state.copyWith(isLoading: false, harvestPrediction: HarvestPredictionResponse.fromJson(data));
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchDiseaseRisk(DiseaseRiskRequest request) async {
    state = state.copyWith(isLoading: true, error: null, diseaseRisk: null);
    try {
      final response = await ApiClient.instance.post(
        ApiEndpoints.aiDiseaseRisk,
        data: request.toJson(),
      );
      final data = _extractData(response);
      state = state.copyWith(isLoading: false, diseaseRisk: DiseaseRiskResponse.fromJson(data));
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchFcrInsights(FcrInsightsRequest request) async {
    state = state.copyWith(isLoading: true, error: null, fcrInsights: null);
    try {
      final response = await ApiClient.instance.post(
        ApiEndpoints.aiFcrInsights,
        data: request.toJson(),
      );
      final data = _extractData(response);
      state = state.copyWith(isLoading: false, fcrInsights: FcrInsightsResponse.fromJson(data));
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> sendMessage(String text) async {
    final userMessage = ChatMessage(role: 'user', content: text);
    final updatedHistory = [...state.chatHistory, userMessage];
    state = state.copyWith(isLoading: true, error: null, chatHistory: updatedHistory);

    try {
      final response = await ApiClient.instance.post(
        ApiEndpoints.aiChat,
        data: ChatRequest(message: text, history: state.chatHistory).toJson(),
      );
      final data = _extractData(response);
      final aiResponse = ChatResponse.fromJson(data);
      
      final aiMessage = ChatMessage(role: 'assistant', content: aiResponse.response);
      state = state.copyWith(
        isLoading: false,
        chatHistory: [...state.chatHistory, aiMessage],
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  dynamic _extractData(dynamic response) {
    return response.data is Map<String, dynamic> && response.data.containsKey('data')
        ? response.data['data']
        : response.data;
  }

  void clearState() {
    state = AiInsightsState();
  }
}

final aiInsightsProvider = NotifierProvider<AiInsightsNotifier, AiInsightsState>(
  AiInsightsNotifier.new,
);


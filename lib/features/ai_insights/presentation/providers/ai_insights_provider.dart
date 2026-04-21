import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/ai_insights/data/models/feed_recommendation.dart';
import 'package:mobile/features/ai_insights/data/models/mortality_analysis.dart';
import 'package:mobile/features/ai_insights/data/models/harvest_prediction.dart';
import 'package:mobile/features/ai_insights/data/models/disease_risk.dart';
import 'package:mobile/features/ai_insights/data/models/fcr_insights.dart';
import 'package:mobile/features/ai_insights/data/models/ai_chat.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/api_endpoints.dart';
import 'package:mobile/core/utils/error_handler.dart';
import 'package:mobile/shared/providers/data_providers.dart';

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
    final features = List<String>.from(ref.read(planDetailsProvider).value?['features'] ?? []);
    final isAdmin = ref.read(profileProvider).value?.isAdmin == true;
    if (!isAdmin && !features.contains('ai_advisory')) {
      state = state.copyWith(error: 'AI Advisory requires an Enterprise Plan');
      return;
    }
    
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await ApiClient.instance.post(
        ApiEndpoints.aiFeedRecommendation,
        data: request.toJson(),
      );
      final data = _extractData(response);
      state = state.copyWith(isLoading: false, recommendation: FeedRecommendationResponse.fromJson(data));
    } catch (e) {
      state = state.copyWith(isLoading: false, error: getFriendlyErrorMessage(e));
    }
  }

  Future<void> fetchMortalityAnalysis(MortalityAnalysisRequest request) async {
    final features = List<String>.from(ref.read(planDetailsProvider).value?['features'] ?? []);
    final isAdmin = ref.read(profileProvider).value?.isAdmin == true;
    if (!isAdmin && !features.contains('ai_advisory')) {
      state = state.copyWith(error: 'AI Advisory requires an Enterprise Plan');
      return;
    }

    state = state.copyWith(isLoading: true, error: null, mortalityAnalysis: null);
    try {
      final response = await ApiClient.instance.post(
        ApiEndpoints.aiMortalityAnalysis,
        data: request.toJson(),
      );
      final data = _extractData(response);
      state = state.copyWith(isLoading: false, mortalityAnalysis: MortalityAnalysisResponse.fromJson(data));
    } catch (e) {
      state = state.copyWith(isLoading: false, error: getFriendlyErrorMessage(e));
    }
  }

  Future<void> fetchHarvestPrediction(HarvestPredictionRequest request) async {
    final features = List<String>.from(ref.read(planDetailsProvider).value?['features'] ?? []);
    final isAdmin = ref.read(profileProvider).value?.isAdmin == true;
    if (!isAdmin && !features.contains('ai_advisory')) {
      state = state.copyWith(error: 'AI Advisory requires an Enterprise Plan');
      return;
    }

    state = state.copyWith(isLoading: true, error: null, harvestPrediction: null);
    try {
      final response = await ApiClient.instance.post(
        ApiEndpoints.aiHarvestPrediction,
        data: request.toJson(),
      );
      final data = _extractData(response);
      state = state.copyWith(isLoading: false, harvestPrediction: HarvestPredictionResponse.fromJson(data));
    } catch (e) {
      state = state.copyWith(isLoading: false, error: getFriendlyErrorMessage(e));
    }
  }

  Future<void> fetchDiseaseRisk(DiseaseRiskRequest request) async {
    final features = List<String>.from(ref.read(planDetailsProvider).value?['features'] ?? []);
    final isAdmin = ref.read(profileProvider).value?.isAdmin == true;
    if (!isAdmin && !features.contains('ai_advisory')) {
      state = state.copyWith(error: 'AI Advisory requires an Enterprise Plan');
      return;
    }

    state = state.copyWith(isLoading: true, error: null, diseaseRisk: null);
    try {
      final response = await ApiClient.instance.post(
        ApiEndpoints.aiDiseaseRisk,
        data: request.toJson(),
      );
      final data = _extractData(response);
      state = state.copyWith(isLoading: false, diseaseRisk: DiseaseRiskResponse.fromJson(data));
    } catch (e) {
      state = state.copyWith(isLoading: false, error: getFriendlyErrorMessage(e));
    }
  }

  Future<void> fetchFcrInsights(FcrInsightsRequest request) async {
    final features = List<String>.from(ref.read(planDetailsProvider).value?['features'] ?? []);
    final isAdmin = ref.read(profileProvider).value?.isAdmin == true;
    if (!isAdmin && !features.contains('ai_advisory')) {
      state = state.copyWith(error: 'AI Advisory requires an Enterprise Plan');
      return;
    }

    state = state.copyWith(isLoading: true, error: null, fcrInsights: null);
    try {
      final response = await ApiClient.instance.post(
        ApiEndpoints.aiFcrInsights,
        data: request.toJson(),
      );
      final data = _extractData(response);
      state = state.copyWith(isLoading: false, fcrInsights: FcrInsightsResponse.fromJson(data));
    } catch (e) {
      state = state.copyWith(isLoading: false, error: getFriendlyErrorMessage(e));
    }
  }

  Future<void> sendMessage(String text) async {
    final features = List<String>.from(ref.read(planDetailsProvider).value?['features'] ?? []);
    final isAdmin = ref.read(profileProvider).value?.isAdmin == true;
    if (!isAdmin && !features.contains('ai_chat')) {
      state = state.copyWith(error: 'AI Chat requires an Enterprise Plan');
      return;
    }

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
      state = state.copyWith(isLoading: false, error: getFriendlyErrorMessage(e));
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


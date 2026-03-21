import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client_provider.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/feed_recommendation.dart';

final aiInsightsRepositoryProvider = Provider<AiInsightsRepository>((ref) {
  final dio = ref.watch(apiClientProvider);
  return AiInsightsRepository(dio: dio);
});

class AiInsightsRepository {
  final Dio dio;
  AiInsightsRepository({required this.dio});

  Future<FeedRecommendationResponse> getFeedRecommendation(FeedRecommendationRequest request) async {
    try {
      final response = await dio.post(
        ApiEndpoints.aiFeedRecommendation,
        data: request.toJson(),
      );
      return FeedRecommendationResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch AI Feed Advisory: $e');
    }
  }
}

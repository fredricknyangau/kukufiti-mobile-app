import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client_provider.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../providers/data_providers.dart';
import '../models/feed_recommendation.dart';

final aiInsightsRepositoryProvider = Provider<AiInsightsRepository>((ref) {
  final dio = ref.watch(apiClientProvider);
  return AiInsightsRepository(dio: dio, ref: ref);
});

class AiInsightsRepository {
  final Dio dio;
  final Ref ref;

  AiInsightsRepository({required this.dio, required this.ref});

  Future<FeedRecommendationResponse> getFeedRecommendation(FeedRecommendationRequest request) async {
    final sub = ref.read(subscriptionProvider).value;
    final plan = sub?['plan_type'] ?? 'STARTER';
    if (plan != 'ENTERPRISE') {
      throw Exception('AI Insights require an Enterprise Plan. Please upgrade to access this feature.');
    }

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

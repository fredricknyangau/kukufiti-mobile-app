import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/api_client_provider.dart';
import 'package:mobile/core/network/api_endpoints.dart';
import 'package:mobile/shared/providers/data_providers.dart';
import 'package:mobile/features/ai_insights/data/models/feed_recommendation.dart';

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
    final profile = ref.read(profileProvider).value;
    final plan = sub?['plan_type'] ?? 'STARTER';
    if (profile?.isAdmin != true && plan != 'ENTERPRISE') {
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

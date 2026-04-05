import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_endpoints.dart';
import '_provider_utils.dart';
import '../core/models/broiler_models.dart';

final biosecurityProvider = FutureProvider.autoDispose<List<BiosecurityCheck>>((ref) async {
  setupKeepAlive(ref);
  return fetchWithFallback(
    endpoint: ApiEndpoints.biosecurity,
    fromJson: BiosecurityCheck.fromJson,
  );
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_endpoints.dart';
import '_provider_utils.dart';

final alertsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  setupKeepAlive(ref);
  return fetchListWithFallback(
    endpoint: ApiEndpoints.alerts,
  );
});

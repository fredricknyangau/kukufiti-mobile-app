import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/api_endpoints.dart';
import 'package:mobile/shared/utils/_provider_utils.dart';
import 'package:mobile/core/models/broiler_models.dart';

final biosecurityProvider = FutureProvider.autoDispose<List<BiosecurityCheck>>((ref) async {
  setupKeepAlive(ref);
  return fetchWithFallback(
    endpoint: ApiEndpoints.biosecurity,
    fromJson: BiosecurityCheck.fromJson,
  );
});

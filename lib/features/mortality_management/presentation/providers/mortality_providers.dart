import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/models/broiler_models.dart';
import 'package:mobile/core/network/api_endpoints.dart';
import 'package:mobile/shared/utils/_provider_utils.dart';

final mortalityProvider = FutureProvider.autoDispose<List<MortalityRecord>>((ref) async {
  setupKeepAlive(ref);
  return fetchWithFallback(
    endpoint: ApiEndpoints.mortality,
    fromJson: MortalityRecord.fromJson,
  );
});

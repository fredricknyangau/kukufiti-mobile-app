import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/models/broiler_models.dart';
import 'package:mobile/core/network/api_endpoints.dart';
import 'package:mobile/shared/utils/_provider_utils.dart';

final dailyChecksProvider = FutureProvider.autoDispose.family<List<DailyCheck>, String>((ref, flockId) async {
  setupKeepAlive(ref);
  return fetchWithFallback(
    endpoint: '${ApiEndpoints.dailyChecks}/$flockId',
    fromJson: DailyCheck.fromJson,
  );
});

// flock_providers.dart — Riverpod providers for flock events (mortality, feed, vaccination, weight, daily checks)
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/models/broiler_models.dart';
import '../core/network/api_endpoints.dart';
import '_provider_utils.dart';

// ── Event providers ───────────────────────────────────────────────────────────

final mortalityProvider = FutureProvider.autoDispose<List<MortalityRecord>>((ref) async {
  setupKeepAlive(ref);
  return fetchWithFallback(
    endpoint: ApiEndpoints.mortality,
    fromJson: MortalityRecord.fromJson,
  );
});

final feedProvider = FutureProvider.autoDispose<List<FeedRecord>>((ref) async {
  setupKeepAlive(ref);
  return fetchWithFallback(
    endpoint: ApiEndpoints.feed,
    fromJson: FeedRecord.fromJson,
  );
});

final vaccinationProvider = FutureProvider.autoDispose<List<VaccinationRecord>>((ref) async {
  setupKeepAlive(ref);
  return fetchWithFallback(
    endpoint: ApiEndpoints.vaccination,
    fromJson: VaccinationRecord.fromJson,
  );
});

final weightProvider = FutureProvider.autoDispose<List<WeightRecord>>((ref) async {
  setupKeepAlive(ref);
  return fetchWithFallback(
    endpoint: ApiEndpoints.weight,
    fromJson: WeightRecord.fromJson,
  );
});

final dailyChecksProvider = FutureProvider.autoDispose.family<List<DailyCheck>, String>((ref, flockId) async {
  setupKeepAlive(ref);
  return fetchWithFallback(
    endpoint: '${ApiEndpoints.dailyChecks}$flockId',
    fromJson: DailyCheck.fromJson,
  );
});

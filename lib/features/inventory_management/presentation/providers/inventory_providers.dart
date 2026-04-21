import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/api_endpoints.dart';
import 'package:mobile/core/models/broiler_models.dart';
import 'package:mobile/shared/providers/data_providers.dart';
import 'package:mobile/shared/utils/_provider_utils.dart';

final inventoryProvider = FutureProvider.autoDispose<List<InventoryItem>>((ref) async {
  setupKeepAlive(ref);
  final planDetails = ref.watch(planDetailsProvider).value;
  final features = List<String>.from(planDetails?['features'] ?? []);

  final profile = ref.watch(profileProvider).value;
  if (profile?.isAdmin != true && !features.contains('inventory')) {
    throw Exception('Inventory requires a Professional Plan');
  }

  return fetchWithFallback(
    endpoint: ApiEndpoints.inventory,
    fromJson: InventoryItem.fromJson,
  );
});

final inventoryHistoryProvider = FutureProvider.autoDispose.family<List<InventoryHistoryRecord>, String>((ref, itemId) async {
  setupKeepAlive(ref);
  return fetchWithFallback(
    endpoint: '${ApiEndpoints.inventory}\$itemId/history',
    fromJson: InventoryHistoryRecord.fromJson,
  );
});

// finance_providers.dart — Riverpod providers for sales, expenditures, inventory
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_endpoints.dart';
import '../core/models/broiler_models.dart';
import 'user_providers.dart';
import 'billing_providers.dart';
import '_provider_utils.dart';

final salesProvider = FutureProvider.autoDispose<List<SaleRecord>>((ref) async {
  setupKeepAlive(ref);
  return fetchWithFallback(
    endpoint: ApiEndpoints.sales,
    fromJson: SaleRecord.fromJson,
  );
});

final expendituresProvider = FutureProvider.autoDispose<List<Expenditure>>((ref) async {
  setupKeepAlive(ref);
  return fetchWithFallback(
    endpoint: ApiEndpoints.expenditures,
    fromJson: Expenditure.fromJson,
  );
});

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
    endpoint: '${ApiEndpoints.inventory}$itemId/history',
    fromJson: InventoryHistoryRecord.fromJson,
  );
});

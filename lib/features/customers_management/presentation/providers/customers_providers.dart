import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/api_endpoints.dart';
import 'package:mobile/core/models/people_models.dart';
import 'package:mobile/shared/utils/_provider_utils.dart';

final customersProvider = FutureProvider.autoDispose<List<Customer>>((ref) async {
  setupKeepAlive(ref);
  return fetchWithFallback(
    endpoint: ApiEndpoints.people('customer'),
    fromJson: Customer.fromJson,
  );
});

// people_providers.dart — suppliers, customers, employees
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_endpoints.dart';
import '../core/models/people_models.dart';
import '_provider_utils.dart';

final suppliersProvider = FutureProvider.autoDispose<List<Supplier>>((ref) async {
  setupKeepAlive(ref);
  return fetchWithFallback(
    endpoint: ApiEndpoints.people('supplier'),
    fromJson: Supplier.fromJson,
  );
});

final customersProvider = FutureProvider.autoDispose<List<Customer>>((ref) async {
  setupKeepAlive(ref);
  return fetchWithFallback(
    endpoint: ApiEndpoints.people('customer'),
    fromJson: Customer.fromJson,
  );
});

final employeesProvider = FutureProvider.autoDispose<List<Employee>>((ref) async {
  setupKeepAlive(ref);
  return fetchWithFallback(
    endpoint: ApiEndpoints.people('employee'),
    fromJson: Employee.fromJson,
  );
});

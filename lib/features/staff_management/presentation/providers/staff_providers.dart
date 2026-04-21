import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/api_endpoints.dart';
import 'package:mobile/core/models/people_models.dart';
import 'package:mobile/shared/utils/_provider_utils.dart';

final employeesProvider = FutureProvider.autoDispose<List<Employee>>((ref) async {
  setupKeepAlive(ref);
  return fetchWithFallback(
    endpoint: ApiEndpoints.people('employee'),
    fromJson: Employee.fromJson,
  );
});

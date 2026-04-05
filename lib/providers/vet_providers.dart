import 'package:flutter_riverpod/flutter_riverpod.dart';
import '_provider_utils.dart';

final vetConsultationsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  setupKeepAlive(ref);
  return fetchListWithFallback(endpoint: '/vet');
});

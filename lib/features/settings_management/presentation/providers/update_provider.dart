import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/services/update_service.dart';

final updateCheckProvider = FutureProvider<UpdateInfo?>((ref) async {
  return UpdateService.checkForUpdate();
});

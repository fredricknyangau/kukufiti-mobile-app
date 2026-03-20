import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/update_service.dart';

final updateCheckProvider = FutureProvider<UpdateInfo?>((ref) async {
  return UpdateService.checkForUpdate();
});

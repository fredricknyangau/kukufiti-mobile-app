import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:mobile/app/app.dart';
import 'package:mobile/core/notifications/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notification service
  await NotificationService.initialize();
  
  // Initialize Hive for offline storage
  await Hive.initFlutter();
  await Hive.openBox('offline_cache');
  await Hive.openBox('offline_sync_queue');

  runApp(
    const ProviderScope(
      child: RootApp(),
    ),
  );
}

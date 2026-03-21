import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/config/app_config.dart';
import 'core/notifications/notification_service.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings_management/presentation/controllers/settings_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notification service
  await NotificationService.initialize();
  
  // Initialize Hive for offline storage
  await Hive.initFlutter();
  await Hive.openBox('offline_cache');

  final bool configIsInvalid = kReleaseMode && AppConfig.isUsingDefaultApiUrl;

  runApp(
    ProviderScope(
      child: configIsInvalid ? const ConfigErrorApp() : const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the routerProvider to react to auth changes
    final router = ref.watch(routerProvider);
    final settings = ref.watch(settingsProvider);

    return MaterialApp.router(
      title: 'KukuFiti',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

class ConfigErrorApp extends StatelessWidget {
  const ConfigErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KukuFiti — Configuration Error',
      theme: AppTheme.lightTheme,
      home: Scaffold(
        appBar: AppBar(title: const Text('Configuration Error')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Missing backend URL',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'The app is running in release mode but the backend API URL is not configured.\n\n'
                  'Please rebuild the app with a valid backend URL using:\n'
                  '`--dart-define=API_URL=https://your-backend/api/v1`',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    debugPrint('Reload requested');
                  },
                  child: const Text('Retry (restart app)'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

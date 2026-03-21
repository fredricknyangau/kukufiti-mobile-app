import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/config/app_config.dart';
import 'core/notifications/notification_service.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings_management/presentation/controllers/settings_controller.dart';

class ConfigInvalidNotifier extends Notifier<bool> {
  @override
  bool build() {
    return kReleaseMode && AppConfig.isUsingDefaultApiUrl;
  }

  void setInvalid(bool value) {
    state = value;
  }
}

final configInvalidProvider = NotifierProvider<ConfigInvalidNotifier, bool>(() {
  return ConfigInvalidNotifier();
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notification service
  await NotificationService.initialize();
  
  // Initialize Hive for offline storage
  await Hive.initFlutter();
  await Hive.openBox('offline_cache');

  runApp(
    const ProviderScope(
      child: RootApp(),
    ),
  );
}

class RootApp extends ConsumerWidget {
  const RootApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isInvalid = ref.watch(configInvalidProvider);
    return isInvalid ? const ConfigErrorApp() : const MyApp();
  }
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

class ConfigErrorApp extends ConsumerStatefulWidget {
  const ConfigErrorApp({super.key});

  @override
  ConsumerState<ConfigErrorApp> createState() => _ConfigErrorAppState();
}

class _ConfigErrorAppState extends ConsumerState<ConfigErrorApp> {
  final _urlController = TextEditingController();
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _urlController.text = AppConfig.apiUrl;
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _saveUrl() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      setState(() => _errorText = 'URL cannot be empty');
      return;
    }

    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      setState(() => _errorText = 'URL must start with http:// or https://');
      return;
    }

    try {
      final box = Hive.box('offline_cache');
      await box.put('API_URL', url);
      ref.read(configInvalidProvider.notifier).setInvalid(false);
    } catch (e) {
      setState(() => _errorText = 'Save failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KukuFiti — Configuration',
      theme: AppTheme.lightTheme,
      home: Scaffold(
        appBar: AppBar(title: const Text('Backend Configuration')),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Missing or Default Backend URL',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'The app is running in release mode. Please enter your backend URL to continue.\n\n'
                  'Example: http://192.168.100.45:8000/api/v1',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _urlController,
                  decoration: InputDecoration(
                    labelText: 'Backend API URL',
                    hintText: 'http://<ip-address>:8000/api/v1',
                    border: const OutlineInputBorder(),
                    errorText: _errorText,
                  ),
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _saveUrl,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Save & Connect'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

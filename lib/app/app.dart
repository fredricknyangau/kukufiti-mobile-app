import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';

import 'package:mobile/core/config/app_config.dart';
import 'package:mobile/app/router.dart';
import 'package:mobile/app/theme/app_theme.dart';
import 'package:mobile/core/network/connectivity_service.dart';
import 'package:mobile/features/settings_management/presentation/controllers/settings_controller.dart';

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
    final router = ref.watch(routerProvider);
    final settings = ref.watch(settingsProvider);
    final connectivity = ref.watch(connectivityProvider);

    return MaterialApp.router(
      title: 'KukuFiti',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return Column(
          children: [
            if (connectivity == ConnectivityStatus.isDisconnected)
              Material(
                child: Container(
                  width: double.infinity,
                  color: Colors.red.shade800,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: const SafeArea(
                    bottom: false,
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.cloud_off, color: Colors.white, size: 16),
                          SizedBox(width: 8),
                          Text(
                            'You are offline',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            Expanded(child: child ?? const SizedBox()),
          ],
        );
      },
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
      setState(() => _errorText = 'Save failed: \$e');
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
                  'Example: http://192.168.100.45:8080/api/v1',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _urlController,
                  decoration: InputDecoration(
                    labelText: 'Backend API URL',
                    hintText: 'http://<ip-address>:8080/api/v1',
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

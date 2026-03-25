import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/main.dart';
import 'package:hive/hive.dart';
import 'dart:io';
import 'package:flutter/services.dart';

void main() {
  // Setup Hive and Mock Secure Storage for testing
  setUpAll(() async {
    // Mock the MethodChannel for flutter_secure_storage
    TestWidgetsFlutterBinding.ensureInitialized();
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

    messenger.setMockMethodCallHandler(
      const MethodChannel('plugins.it_solutions.com.br/flutter_secure_storage'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'read') return null;
        return null;
      },
    );

    // Mock flutter_local_notifications
    messenger.setMockMethodCallHandler(
      const MethodChannel('dexterous.com/flutter_local_notifications'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'initialize') return true;
        if (methodCall.method == 'getNotificationAppLaunchDetails') return null;
        return null;
      },
    );

    final tempDir = Directory.systemTemp.createTempSync();
    Hive.init(tempDir.path);
    await Hive.openBox('offline_cache');
    await Hive.openBox('offline_sync_queue');
  });

  testWidgets('App builds and renders without crashing', (WidgetTester tester) async {
    // We build RootApp which handles both ConfigErrorApp and MyApp logic
    await tester.pumpWidget(
      const ProviderScope(
        child: RootApp(),
      ),
    );

    // Initial pump to trigger the first frame and build the providers
    await tester.pump();

    // Verify Splash Screen or Config screen is shown initially
    // Since kDebugMode is true in tests, AppConfig.isUsingDefaultApiUrl might trigger ConfigErrorApp
    // but the router initial location is '/' which is SplashScreen.
    final splashText = find.text('KukuFiti');
    if (splashText.evaluate().isNotEmpty) {
      expect(splashText, findsOneWidget);
    } else {
      // Fallback for ConfigErrorApp if it bypasses splash in test environment
      expect(find.byType(MaterialApp), findsOneWidget);
    }

    // Advance past the 2-second splash delay in _initializeApp.
    // Cannot use pumpAndSettle() — CircularProgressIndicator runs an infinite animation.
    await tester.pump(const Duration(seconds: 2));

    // _navigate() may retry every 500ms while authState.isLoading == true.
    // Drain up to 10 retries (5 seconds) to ensure all timers fire before dispose.
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }

    // Final pump for any navigation transition triggered by GoRouter
    await tester.pump();

    // Basic assertion to check if the app is still alive and rendering a MaterialApp
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

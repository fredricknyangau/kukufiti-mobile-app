import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/main.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Initialize Hive for testing
    await Hive.initFlutter();
    await Hive.openBox('offline_cache');

    // Build our app and trigger a frame.
    // Wrapped in ProviderScope because MyApp uses Riverpod
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    // Verify that the app starts (MaterialApp is present)
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

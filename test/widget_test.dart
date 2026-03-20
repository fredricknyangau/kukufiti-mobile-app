import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/main.dart';
import 'package:hive/hive.dart';
import 'dart:io';

void main() {
  // Setup Hive for testing in a temporary directory
  setUpAll(() async {
    final tempDir = Directory.systemTemp.createTempSync();
    Hive.init(tempDir.path);
    await Hive.openBox('offline_cache');
  });

  testWidgets('App builds and renders without crashing', (WidgetTester tester) async {
    // We build MyApp directly. 
    // If MyApp uses providers that require Hive, it will use the box opened in setUpAll.
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    // Basic assertion to check if the app started
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

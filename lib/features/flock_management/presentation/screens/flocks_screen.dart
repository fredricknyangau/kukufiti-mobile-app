import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The `/flocks` route is an alias for the Batch Management screen.
/// This redirect ensures deep-links or drawer items pointing to /flocks
/// always land on the correct, fully-implemented screen.
class FlocksScreen extends StatelessWidget {
  const FlocksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Immediately redirect to the Batch Management screen.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.replace('/batches');
    });

    // Show a brief loading indicator while the redirect fires.
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

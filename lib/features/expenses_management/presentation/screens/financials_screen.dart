import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The `/financials` route redirects to the Expenditures screen,
/// which is the fully implemented financial management screen.
class FinancialsScreen extends StatelessWidget {
  const FinancialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.replace('/expenditures');
    });

    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

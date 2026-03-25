import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  Timer? _splashTimer;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    // 1. Pre-cache critical images for smoother transition
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _precacheImages();
    });

    // 2. Wait for at least 2 seconds AND for auth hydration
    await Future.delayed(const Duration(seconds: 2));
    
    // We wait until the auth state is no longer loading (initialized)
    // If it's still loading, we use a listener in a loop or a more robust method.
    // However, since we are in a Future-based _initializeApp, we can check it.
    
    if (!mounted) return;
    _navigate();
  }

  void _navigate() {
    final authState = ref.read(authProvider);
    
    // If auth is still loading, wait another 500ms and try again.
    // Use a stored Timer so dispose() can cancel it and avoid test leaks.
    if (authState.isLoading) {
      _splashTimer = Timer(const Duration(milliseconds: 500), _navigate);
      return;
    }

    final isAuthenticated = authState.isAuthenticated;
    final hasSeenIntro = authState.hasSeenIntro;

    if (isAuthenticated) {
      context.go('/dashboard');
    } else if (hasSeenIntro) {
      context.go('/login');
    } else {
      context.go('/welcome');
    }
  }

  void _precacheImages() {
    if (!mounted) return;
    precacheImage(const AssetImage('assets/images/chicken_logo.jpeg'), context);
    precacheImage(const AssetImage('assets/images/hero_image.jpg'), context);
  }

  @override
  Widget build(BuildContext context) {
    // Warm Background consistent with onboarding
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                'assets/images/chicken_logo.jpeg',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.image, size: 50, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Title or tagline could go here
            Text(
              'KukuFiti',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

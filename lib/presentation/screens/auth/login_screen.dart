import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/utils/toast_service.dart';
import '../../../core/services/biometric_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_input.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _canCheckBiometrics = false;
  bool _rememberMe = true;

  @override
  void initState() {
    super.initState();
    _loadRememberedEmail();
    _checkBiometrics();
  }

  Future<void> _loadRememberedEmail() async {
    final email = await SecureStorageService.getRememberedEmail();
    if (email != null && mounted) {
      _emailController.text = email;
    }
  }

  Future<void> _checkBiometrics() async {
    final canCheck = await BiometricService.canCheckBiometrics();
    if (mounted) {
      setState(() => _canCheckBiometrics = canCheck);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleBiometricLogin() async {
    final token = await SecureStorageService.getAuthToken();
    if (token == null || token.isEmpty) {
      if (mounted) {
        ToastService.showError(context, 'Please sign in with password first');
      }
      return;
    }

    final success = await BiometricService.authenticate();
    if (success && mounted) {
      HapticFeedback.heavyImpact();
      ref.read(authProvider.notifier).loginWithToken(token);
      ToastService.showSuccess(context, "Welcome back!");
      context.go('/dashboard');
    }
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();

    await ref.read(authProvider.notifier).login(
          email,
          _passwordController.text,
        );
        
    if (!mounted) return;

    final authState = ref.read(authProvider);
    if (authState.isAuthenticated) {
      // Handle Remember Me persistence
      if (_rememberMe) {
        await SecureStorageService.saveRememberedEmail(email);
      } else {
        await SecureStorageService.clearRememberedEmail();
      }

      if (!mounted) return;

      ToastService.showSuccess(context, "Welcome back!");
      context.go('/dashboard');
    } else if (authState.error != null) {
      ToastService.showError(context, authState.error!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background mesh glows
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.12 : 0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.08 : 0.04),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: CustomCard(
                  isPremium: true,
                  padding: const EdgeInsets.all(32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                'assets/images/chicken_logo.jpeg',
                                width: 56,
                                height: 56,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Welcome Back',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: theme.colorScheme.onSurface,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sign in to your KukuFiti command panel',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        CustomInput(
                          label: 'Email',
                          hintText: 'yourname@example.com',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(LucideIcons.mail, size: 20),
                          validator: (value) => value == null || value.isEmpty ? 'Enter email' : null,
                        ),
                        const SizedBox(height: 20),
                        CustomInput(
                          label: 'Password',
                          hintText: 'Enter password',
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          prefixIcon: const Icon(LucideIcons.lock, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? LucideIcons.eye : LucideIcons.eyeOff,
                              size: 18,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          validator: (value) => value == null || value.isEmpty ? 'Enter password' : null,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: Checkbox(
                                value: _rememberMe,
                                onChanged: (val) => setState(() => _rememberMe = val ?? false),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text('Remember Me', style: TextStyle(fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        CustomButton(
                          text: 'Sign In',
                          onPressed: _handleLogin,
                          isLoading: authState.isLoading,
                        ),
                        if (_canCheckBiometrics) ...[
                          const SizedBox(height: 12),
                          CustomButton(
                            variant: CustomButtonVariant.outline,
                            text: 'Unlock with Biometrics',
                            icon: const Icon(LucideIcons.fingerprint, size: 20),
                            onPressed: _handleBiometricLogin,
                          ),
                        ],
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account?",
                              style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                            ),
                            TextButton(
                              onPressed: () => context.push('/register'),
                              child: Text(
                                'Register',
                                style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

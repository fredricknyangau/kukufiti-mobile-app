import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:mobile/core/utils/toast_service.dart';
import 'package:mobile/core/notifications/notification_service.dart';
import 'package:mobile/features/auth_management/presentation/providers/auth_provider.dart';
import 'package:mobile/shared/widgets/custom_button.dart';
import 'package:mobile/shared/widgets/custom_card.dart';
import 'package:mobile/shared/widgets/custom_input.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    
    FocusScope.of(context).unfocus();

    var phone = _phoneController.text.trim();
    if (phone.startsWith('0')) {
      phone = phone.substring(1);
    }
    final fullPhone = '+254$phone';

    final otpCode = await ref.read(authProvider.notifier).sendOtp(fullPhone);
    
    final authState = ref.read(authProvider);
    if (authState.error != null) {
      if (mounted) ToastService.showError(context, authState.error!);
      return;
    }

    if (otpCode != null) {
      await NotificationService.showNotification(
        id: 10,
        title: 'KukuFiti OTP',
        body: 'Your verification code is: $otpCode',
      );
    }

    if (mounted) {
      final encodedPhone = Uri.encodeComponent(fullPhone);
      context.go('/otp-verify?phone=$encodedPhone');
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final isNewUser = await ref.read(authProvider.notifier).signInWithGoogle();
    
    if (!mounted) return;
    
    final authState = ref.read(authProvider);
    if (authState.error != null) {
      ToastService.showError(context, authState.error!);
      return;
    }

    if (isNewUser == true) {
      context.go('/onboarding');
    } else if (isNewUser == false) {
      context.go('/dashboard');
    }
  }

  Future<void> _handleAppleSignIn() async {
    final isNewUser = await ref.read(authProvider.notifier).signInWithApple();
    
    if (!mounted) return;
    
    final authState = ref.read(authProvider);
    if (authState.error != null) {
      ToastService.showError(context, authState.error!);
      return;
    }

    if (isNewUser == true) {
      context.go('/onboarding');
    } else if (isNewUser == false) {
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: Stack(
        children: [
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
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              'assets/images/chicken_logo.jpeg',
                              width: 64,
                              height: 64,
                              fit: BoxFit.contain,
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
                          'Enter your phone number to sign in',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        CustomInput(
                          label: 'Phone Number',
                          hintText: '712345678',
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          prefixIcon: Text('+254', style: TextStyle(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            fontWeight: FontWeight.bold,
                          )),
                          validator: (v) => v == null || v.isEmpty ? 'Enter phone number' : null,
                        ),
                        const SizedBox(height: 32),
                        CustomButton(
                          text: 'Continue with OTP',
                          onPressed: _sendOtp,
                          isLoading: authState.isLoading,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'OR',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(LucideIcons.mail, size: 18),
                                label: const Text('Google', style: TextStyle(fontSize: 13)),
                                onPressed: authState.isLoading ? null : _handleGoogleSignIn,
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(LucideIcons.apple, size: 18),
                                label: const Text('Apple', style: TextStyle(fontSize: 13)),
                                onPressed: authState.isLoading ? null : _handleAppleSignIn,
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ],
                        ),
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

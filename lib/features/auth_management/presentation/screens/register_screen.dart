import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobile/core/utils/toast_service.dart';
import 'package:mobile/core/notifications/notification_service.dart';
import 'package:mobile/features/auth_management/presentation/providers/auth_provider.dart';
import 'package:mobile/shared/widgets/custom_button.dart';
import 'package:mobile/shared/widgets/custom_card.dart';
import 'package:mobile/shared/widgets/custom_input.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Hide keyboard
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
        id: 0,
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
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                value: 0.75,
                backgroundColor: theme.colorScheme.outline,
                color: theme.colorScheme.primary,
                minHeight: 2,
              ),
            ),

            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
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
                            'KukuFiti',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: theme.colorScheme.primary,
                              letterSpacing: -1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create your account to continue',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),

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
                            text: 'Send OTP',
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
                          const SizedBox(height: 32),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(LucideIcons.lock, size: 14, color: theme.colorScheme.primary.withValues(alpha: 0.6)),
                              const SizedBox(width: 8),
                              Text(
                                'Secure & Private. By signing up, you agree to our ',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => context.push('/terms'),
                                child: Text(
                                  'Terms.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Have an account?",
                                style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                              ),
                              TextButton(
                                onPressed: () => context.go('/login'),
                                child: Text(
                                  'Sign in',
                                  style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w900),
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
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

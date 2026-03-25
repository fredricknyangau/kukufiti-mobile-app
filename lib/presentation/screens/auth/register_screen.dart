import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/utils/toast_service.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/services/sso_service.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_input.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final phone = _phoneController.text.trim();
    final fullPhone = '+254$phone';

    try {
      final response = await ApiClient.instance.post(
        ApiEndpoints.sendOtp,
        data: {'phone_number': fullPhone},
      );

      final otpCode = response.data['code']?.toString();
      if (otpCode != null) {
        await NotificationService.showNotification(
          id: 0,
          title: 'KukuFiti OTP',
          body: 'Your verification code is: $otpCode',
        );
      }

      if (mounted) {
        context.push('/otp-verify?phone=$fullPhone');
      }
    } on DioException catch (e) {
      if (mounted) ToastService.showError(context, getFriendlyErrorMessage(e));
    } catch (e) {
      if (mounted) ToastService.showError(context, 'An unexpected error occurred');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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

                          Column(
                            children: [
                              CustomButton(
                                variant: CustomButtonVariant.outline,
                                icon: const Icon(LucideIcons.chrome, size: 20),
                                text: 'Continue with Google',
                                onPressed: () async {
                                  try {
                                    final result = await SsoService.signInWithGoogle();
                                    await ref.read(authProvider.notifier).loginWithToken(result.accessToken);
                                    if (context.mounted) {
                                      ToastService.showSuccess(context, 'Signed in with Google');
                                      if (result.isNewUser) {
                                        context.go('/profile-setup');
                                      } else {
                                        context.go('/dashboard');
                                      }
                                    }
                                  } catch (e) {
                                    if (context.mounted) ToastService.showError(context, e.toString());
                                  }
                                },
                              ),
                              const SizedBox(height: 12),
                              if (SsoService.isAppleSignInAvailable)
                                CustomButton(
                                  variant: CustomButtonVariant.outline,
                                  icon: const Icon(LucideIcons.apple, size: 20),
                                  text: 'Continue with Apple',
                                  onPressed: () async {
                                    try {
                                      final result = await SsoService.signInWithApple();
                                      await ref.read(authProvider.notifier).loginWithToken(result.accessToken);
                                      if (context.mounted) {
                                        ToastService.showSuccess(context, 'Signed in with Apple');
                                        if (result.isNewUser) {
                                          context.go('/profile-setup');
                                        } else {
                                          context.go('/dashboard');
                                        }
                                      }
                                    } catch (e) {
                                      if (context.mounted) ToastService.showError(context, e.toString());
                                    }
                                  },
                                ),
                            ],
                          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),

                          const SizedBox(height: 24),

                          Row(
                            children: [
                              Expanded(child: Divider(color: theme.colorScheme.outline.withValues(alpha: 0.5))),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'or',
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Expanded(child: Divider(color: theme.colorScheme.outline.withValues(alpha: 0.5))),
                            ],
                          ),

                          const SizedBox(height: 24),

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
                            isLoading: _isLoading,
                          ),

                          const SizedBox(height: 32),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(LucideIcons.lock, size: 14, color: theme.colorScheme.primary.withValues(alpha: 0.6)),
                              const SizedBox(width: 8),
                              Text(
                                'Your data is private & encrypted.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
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

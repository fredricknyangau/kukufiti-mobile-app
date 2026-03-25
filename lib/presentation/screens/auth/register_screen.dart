import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/utils/toast_service.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/services/sso_service.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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
        // Navigate with parameter
        context.push('/otp-verify?phone=$fullPhone');
      }
    } on DioException catch (e) {
      if (mounted) {
        ToastService.showError(context, getFriendlyErrorMessage(e));
      }
    } catch (e) {
      if (mounted) {
        ToastService.showError(context, 'An unexpected error occurred');
      }
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
            // ─── PROGRESS BAR ───
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                value: 0.75, // Step 3 of Onboarding
                backgroundColor: theme.colorScheme.outline,
                color: theme.colorScheme.primary,
                minHeight: 2,
              ),
            ),



            // ─── MAIN CONTENT ───
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: theme.colorScheme.outline),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Logo / App Name
                          Text(
                            'KukuFiti',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                              letterSpacing: -0.5,
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

                          // ─── SSO BUTTONS ───
                          Consumer(
                            builder: (context, ref, child) => Column(
                              children: [
                                SizedBox(
                                  height: 56,
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
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
                                    icon: const Icon(LucideIcons.chrome, size: 20),
                                    label: const Text('Continue with Google'),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: theme.colorScheme.outline),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      foregroundColor: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                if (SsoService.isAppleSignInAvailable)
                                  SizedBox(
                                    height: 56,
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
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
                                      icon: const Icon(LucideIcons.apple, size: 20),
                                      label: const Text('Continue with Apple'),
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(color: theme.colorScheme.outline),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        foregroundColor: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // ─── DIVIDER ───
                          Row(
                            children: [
                              Expanded(child: Divider(color: theme.colorScheme.outline)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'or',
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Expanded(child: Divider(color: theme.colorScheme.outline)),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // ─── PHONE INPUT ───
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: 'Phone Number',
                              hintText: '712345678',
                              prefixText: '+254 ',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: theme.colorScheme.outline),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: theme.colorScheme.outline),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                              ),
                              filled: true,
                              fillColor: theme.colorScheme.surface,
                            ),
                            validator: (v) => v == null || v.isEmpty ? 'Enter phone number' : null,
                          ),

                          const SizedBox(height: 24),

                          // ─── SEND OTP BUTTON ───
                          SizedBox(
                            height: 56,
                            child: FilledButton(
                              onPressed: _isLoading ? null : _sendOtp,
                              style: FilledButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Send OTP',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // ─── TRUST SIGNAL ───
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                LucideIcons.lock,
                                size: 14,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Your farm data is private and never shared.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // ─── GOTO LOGIN ───
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Already have an account?",
                                style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                              ),
                              TextButton(
                                onPressed: () => context.go('/login'),
                                child: Text(
                                  'Sign in',
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
      ),
    );

  }
}

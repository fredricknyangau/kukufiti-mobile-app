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
import '../../../core/notifications/notification_service.dart';
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

    var phone = _phoneController.text.trim();
    if (phone.startsWith('0')) {
      phone = phone.substring(1);
    }
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
        final encodedPhone = Uri.encodeComponent(fullPhone);
        context.go('/otp-verify?phone=$encodedPhone');
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
                            isLoading: _isLoading,
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

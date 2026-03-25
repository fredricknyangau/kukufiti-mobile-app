import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/utils/toast_service.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../providers/auth_provider.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String phoneNumber;

  const OtpVerificationScreen({super.key, required this.phoneNumber});

  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  int _timerSeconds = 30;
  Timer? _timer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timerSeconds = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        setState(() {
          _timerSeconds--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  Future<void> _resendOtp() async {
    try {
      final response = await ApiClient.instance.post(
        ApiEndpoints.sendOtp,
        data: {'phone_number': widget.phoneNumber},
      );

      final otpCode = response.data['code']?.toString();
      if (otpCode != null) {
        await NotificationService.showNotification(
          id: 1,
          title: 'KukuFiti OTP',
          body: 'Your verification code is: $otpCode',
        );
      }
      if (mounted) {
        ToastService.showSuccess(context, 'OTP resent successfully');
        _startTimer();
      }
    } on DioException catch (e) {
      if (mounted) ToastService.showError(context, getFriendlyErrorMessage(e));
    } catch (_) {
      if (mounted) ToastService.showError(context, 'Failed to resend OTP');
    }
  }

  Future<void> _verifyOtp() async {
    final code = _controllers.map((c) => c.text.trim()).join();
    if (code.length < 4) {
      ToastService.showError(context, 'Please enter all 4 digits');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiClient.instance.post(
        ApiEndpoints.verifyOtp,
        data: {
          'phone_number': widget.phoneNumber,
          'code': code,
        },
      );

      if (mounted) {
        final token = response.data['access_token'];
        final isNew = response.data['is_new_user'] ?? false;

        if (token != null) {
          // Save and notify auth state
          ref.read(authProvider.notifier).loginWithToken(token);
          
          if (!mounted) return;
          ToastService.showSuccess(context, "Verification Successful!");
          
          if (isNew) {
            context.go('/profile-setup');
          } else {
            context.go('/dashboard');
          }
        } else {
          ToastService.showError(context, 'Authentication failed');
        }
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
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
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
                value: 1.0, // Last step of registration
                backgroundColor: theme.colorScheme.outline,
                color: theme.colorScheme.primary,
                minHeight: 2,
              ),
            ),

            // ─── BACK BUTTON ───
            Positioned(
              top: 12,
              left: 16,
              child: IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(LucideIcons.arrowLeft),
                color: theme.colorScheme.onSurface,
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(
                          LucideIcons.messageSquare,
                          size: 48,
                          // ignore: avoid_hardcoded_color
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Verify Phone',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enter the 4-digit code sent to your phone',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        // ─── OTP DIGIT INPUTS ───
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(4, (index) {
                            return SizedBox(
                              width: 60,
                              height: 60,
                              child: TextField(
                                controller: _controllers[index],
                                focusNode: _focusNodes[index],
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                                maxLength: 1,
                                decoration: InputDecoration(
                                  counterText: '',
                                  filled: true,
                                  fillColor: theme.colorScheme.surface,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: theme.colorScheme.outline),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                                  ),
                                ),
                                onChanged: (value) {
                                  if (value.isNotEmpty) {
                                    if (index < 3) {
                                      _focusNodes[index + 1].requestFocus();
                                    } else {
                                      _focusNodes[index].unfocus();
                                    }
                                  } else {
                                    if (index > 0) {
                                      _focusNodes[index - 1].requestFocus();
                                    }
                                  }
                                },
                              ),
                            );
                          }),
                        ),

                        const SizedBox(height: 32),

                        // ─── VERIFY BUTTON ───
                        SizedBox(
                          height: 56,
                          child: FilledButton(
                            onPressed: _isLoading ? null : _verifyOtp,
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
                                    'Verify & Continue',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ─── RESEND TIMER ───
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Didn't receive code?",
                              style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                            ),
                            TextButton(
                              onPressed: _timerSeconds == 0 ? _resendOtp : null,
                              child: Text(
                                _timerSeconds > 0 ? 'Resend in ${_timerSeconds}s' : 'Resend Code',
                                style: TextStyle(
                                  color: _timerSeconds > 0
                                      ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                                      : theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
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
          ],
        ),
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile/core/utils/toast_service.dart';
import 'package:mobile/features/billing_management/presentation/providers/billing_providers.dart';
import 'package:mobile/shared/widgets/custom_button.dart';
import 'package:mobile/shared/widgets/custom_input.dart';
import 'package:mobile/core/storage/secure_storage_service.dart';

class MpesaPaymentModal extends ConsumerStatefulWidget {
  final Map<String, dynamic> plan;
  final bool isAnnual;

  const MpesaPaymentModal({
    super.key,
    required this.plan,
    required this.isAnnual,
  });

  @override
  ConsumerState<MpesaPaymentModal> createState() => _MpesaPaymentModalState();
}

class _MpesaPaymentModalState extends ConsumerState<MpesaPaymentModal> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isInitiating = false;
  bool _isPolling = false;
  String? _statusMessage;
  Timer? _pollingTimer;
  int _pollCount = 0;
  static const int maxPolls = 30; // 30 polls * 2s = 60s

  @override
  void dispose() {
    _phoneController.dispose();
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _handlePay() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isInitiating = true;
      _statusMessage = 'Initiating payment...';
    });

    final success = await ref.read(billingProvider.notifier).submitSubscription(
      widget.plan['plan_type'],
      widget.isAnnual ? 'yearly' : 'monthly',
      _phoneController.text.trim(),
    );

    if (mounted) {
      if (success) {
        setState(() {
          _isInitiating = false;
          _isPolling = true;
          _statusMessage = 'STK Push sent. Please enter your M-Pesa PIN on your phone.';
        });
        _startPolling();
      } else {
        final error = ref.read(billingProvider).error;
        setState(() {
          _isInitiating = false;
          _statusMessage = 'Error: ${error ?? "Unknown error"}';
        });
        ToastService.showError(context, 'Payment initiation failed: ${error ?? "Unknown error"}');
      }
    }
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      _pollCount++;
      if (_pollCount > maxPolls) {
        timer.cancel();
        if (mounted) {
          setState(() {
            _isPolling = false;
            _statusMessage = 'Payment confirmation timeout. If you paid, it will reflect shortly.';
          });
        }
        return;
      }

      // Invalidate and refresh subscription status
      ref.invalidate(mySubscriptionProvider);
      try {
        final sub = await ref.read(mySubscriptionProvider.future);
        final status = sub['status'];
        final planType = sub['plan_type'];

        if (status == 'ACTIVE' && planType == widget.plan['plan_type']) {
          timer.cancel();
          if (mounted) {
            _handleSuccess();
          }
        } else if (status == 'CANCELLED') {
          timer.cancel();
          if (mounted) {
            setState(() {
              _isPolling = false;
              _statusMessage = 'Payment was cancelled or failed.';
            });
          }
        }
      } catch (e) {
        // Ignore errors during polling (e.g. temporary network issues)
      }
    });
  }

  Future<void> _handleSuccess() async {
    setState(() {
      _isPolling = false;
      _statusMessage = 'Payment Confirmed! Your account is now active.';
    });

    ToastService.showSuccess(context, 'Subscription activated! Redirecting to login...');
    
    // Clear tokens and redirect to auth screens as requested
    await SecureStorageService.deleteAuthToken();
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final price = widget.isAnnual 
        ? (widget.plan['yearly_price'] ?? widget.plan['monthly_price'])
        : widget.plan['monthly_price'];

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
        left: 24,
        right: 24,
        top: 12,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(LucideIcons.smartphone, color: theme.colorScheme.primary, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'M-PESA PAYMENT',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Text(
                        widget.plan['name'],
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Amount',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'KES $price',
                          style: const TextStyle(
                            fontSize: 24, 
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.isAnnual ? 'YEARLY' : 'MONTHLY',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            if (!_isPolling) ...[
              CustomInput(
                label: 'Phone Number',
                hintText: 'e.g. 0712 345 678',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(LucideIcons.phone, size: 20),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Required';
                  if (!RegExp(r'^(254|0)(7|1)\d{8}$').hasMatch(val)) {
                    return 'Invalid M-Pesa Number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Pay with M-Pesa',
                onPressed: _handlePay,
                isLoading: _isInitiating,
                icon: LucideIcons.send,
              ),
            ] else ...[
              Center(
                child: Column(
                  children: [
                    SizedBox(
                      height: 80,
                      width: 80,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            strokeWidth: 6,
                            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                          ),
                          Icon(LucideIcons.lock, color: theme.colorScheme.primary, size: 32),
                        ],
                      ),
                    ).animate(onPlay: (controller) => controller.repeat())
                     .shimmer(duration: 2.seconds, color: Colors.white.withValues(alpha: 0.5)),
                    const SizedBox(height: 32),
                    Text(
                      'Waiting for PIN...',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
            ],
            if (_statusMessage != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isPolling ? LucideIcons.info : LucideIcons.alertCircle,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _statusMessage!,
                        style: TextStyle(
                          fontSize: 13, 
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),
            ],
            const SizedBox(height: 24),
            if (!_isPolling && !_isInitiating)
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

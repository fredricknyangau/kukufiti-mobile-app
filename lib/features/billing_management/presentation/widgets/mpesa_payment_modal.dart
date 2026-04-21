import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
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

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
        left: 24,
        right: 24,
        top: 32,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(LucideIcons.creditCard, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'Upgrade to ${widget.plan['name']}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Complete your subscription to access premium features.',
              style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    'KES $price',
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold, 
                      color: theme.colorScheme.primary
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (!_isPolling) ...[
              CustomInput(
                label: 'M-Pesa Phone Number',
                hintText: 'e.g. 254712345678',
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
              const SizedBox(height: 24),
              CustomButton(
                text: 'Pay with M-Pesa',
                onPressed: _handlePay,
                isLoading: _isInitiating,
                icon: LucideIcons.send,
              ),
            ] else ...[
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 24),
                  ],
                ),
              ),
            ],
            if (_statusMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _statusMessage!,
                  style: TextStyle(
                    fontSize: 13, 
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    fontStyle: FontStyle.italic
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            const SizedBox(height: 16),
            TextButton(
              onPressed: _isPolling || _isInitiating ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:mobile/presentation/widgets/custom_divider.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/public_drawer.dart';
import 'package:go_router/go_router.dart';

class PricingScreen extends StatefulWidget {
  const PricingScreen({super.key});

  @override
  State<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen> {
  bool _isAnnual = true;
  List<dynamic> _plans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPlans();
  }

  Future<void> _fetchPlans() async {
    try {
      final response = await ApiClient.instance.get(ApiEndpoints.plans);
      if (mounted) {
        setState(() {
          _plans = response.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      drawer: const PublicDrawer(),
      appBar: AppBar(
        title: const Text('Pricing', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.15 : 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -50,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.1 : 0.05),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'Simple, transparent pricing',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No hidden fees. Scale your farm profit.',
                    style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Billing Toggle
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildToggleItem('Monthly', !_isAnnual),
                        _buildToggleItem('Anually (-20%)', _isAnnual),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_plans.isEmpty)
                    const Center(child: Text('No plans available.'))
                  else
                    ..._plans.map((plan) {
                      final price = _isAnnual 
                          ? (plan['annual_price'] ?? plan['monthly_price'])
                          : plan['monthly_price'];
                      final period = _isAnnual 
                          ? (plan['annual_price'] != null ? '/year' : plan['period'])
                          : plan['period'];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: _buildPlanCard(
                          theme: theme,
                          title: plan['name'],
                          price: price,
                          period: period,
                          desc: plan['description'],
                          features: List<String>.from(plan['features']),
                          isPremium: plan['popular'],
                          cta: plan['cta'] ?? 'Get Started',
                          onPressed: () => _handleGetStarted(plan),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem(String label, bool isActive) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => setState(() => _isAnnual = label.startsWith('Anu') || label.contains('(-20%)')),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isActive ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required ThemeData theme,
    required String title,
    required String price,
    required String period,
    required String desc,
    required List<String> features,
    required bool isPremium,
    required String cta,
    required VoidCallback onPressed,
  }) {
    return CustomCard(
      isPremium: true,
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: isPremium
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.04),
                    theme.colorScheme.primary.withValues(alpha: 0.0),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              )
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                if (isPremium)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Popular',
                      style: TextStyle(color: theme.colorScheme.primary, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(desc, style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 13)),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(price, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                Text(period, style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 14)),
              ],
            ),
            const SizedBox(height: 24),
            const CustomDivider(),
            const SizedBox(height: 16),
            ...features.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Icon(LucideIcons.checkCircle2, color: theme.colorScheme.primary, size: 18),
                      const SizedBox(width: 12),
                      Expanded(child: Text(f, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
                    ],
                  ),
                )),
            const SizedBox(height: 16),
            CustomButton(
              text: cta,
              onPressed: onPressed,
              variant: isPremium ? CustomButtonVariant.primary : CustomButtonVariant.outline,
            ),
          ],
        ),
      ),
    );
  }

  void _handleGetStarted(Map<String, dynamic> plan) async {
    final token = await SecureStorageService.getAuthToken();
    if (token == null || token.isEmpty) {
      if (mounted) {
        context.push('/login');
      }
      return;
    }

    if (plan['id'] == 'STARTER') {
      if (mounted) context.go('/dashboard');
      return;
    }

    if (plan['id'] == 'ENTERPRISE') {
      if (mounted) context.push('/contact');
      return;
    }

    if (mounted) {
      _showMpesaPrompt(plan);
    }
  }

  void _showMpesaPrompt(Map<String, dynamic> plan) {
    final phoneController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Subscribe to ${plan['name']}', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Amount: ${_isAnnual ? (plan['annual_price'] ?? plan['monthly_price']) : plan['monthly_price']}'),
                const SizedBox(height: 16),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'M-Pesa Phone Number',
                    hintText: '2547XXXXXXXX',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Required';
                    if (!RegExp(r'^(2547|2541|07|01)\d{8}$').hasMatch(val)) {
                      return 'Invalid Phone Number';
                    }
                    return null;
                  },
                )
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context);
                  _submitSubscription(plan, phoneController.text.trim());
                }
              },
              child: const Text('Pay with M-Pesa'),
            ),
          ],
        );
      },
    );
  }

  void _submitSubscription(Map<String, dynamic> plan, String phone) async {
    try {
      final payload = {
        'plan_type': plan['id'],
        'billing_period': _isAnnual ? 'yearly' : 'monthly',
        'phone_number': phone,
      };

      await ApiClient.instance.post(ApiEndpoints.subscribe, data: payload);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('STK Push initiated. Please enter M-Pesa pin on your phone.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Subscription failed: $e')),
        );
      }
    }
  }
}

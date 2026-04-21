import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/app/theme/app_theme.dart';
import 'package:mobile/core/storage/secure_storage_service.dart';
import 'package:mobile/shared/widgets/custom_button.dart';
import 'package:mobile/shared/widgets/custom_card.dart';
import 'package:mobile/shared/widgets/custom_divider.dart';
import 'package:mobile/shared/widgets/public_drawer.dart';
import 'package:mobile/shared/widgets/public_mesh_background.dart';
import 'package:mobile/features/billing_management/presentation/providers/billing_providers.dart';
import 'package:mobile/features/billing_management/presentation/widgets/mpesa_payment_modal.dart';

class PricingScreen extends ConsumerStatefulWidget {
  const PricingScreen({super.key});

  @override
  ConsumerState<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends ConsumerState<PricingScreen> {
  bool _isAnnual = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(billingProvider.notifier).fetchPlans();
      ref.invalidate(mySubscriptionProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final billingState = ref.watch(billingProvider);
    final mySubAsync = ref.watch(mySubscriptionProvider);

    return Scaffold(
      drawer: const PublicDrawer(),
      appBar: AppBar(
        title: const Text('Pricing', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: PublicMeshBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 16),
                const Text(
                  'Simple, transparent pricing',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
                const SizedBox(height: 8),
                Text(
                  'No hidden fees. Scale your farm profit.',
                  style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
                const SizedBox(height: 32),

                // Billing Toggle
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildToggleItem('Monthly', !_isAnnual),
                      _buildToggleItem('Annually', _isAnnual),
                    ],
                  ),
                ).animate().fadeIn(delay: 400.ms),
                const SizedBox(height: 40),

                if (billingState.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (billingState.plans.isEmpty)
                  const Center(child: Text('No plans available.'))
                else ...[
                  if (mySubAsync.hasError && !mySubAsync.isLoading)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Note: Could not refresh subscription status. Some buttons may show "Get Started".',
                          style: TextStyle(color: theme.colorScheme.error, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ...billingState.plans.asMap().entries.map((entry) {
                    final index = entry.key;
                    final plan = entry.value;
                    final price = _isAnnual 
                        ? (plan['yearly_price'] ?? plan['monthly_price'])
                        : plan['monthly_price'];
                    final period = _isAnnual 
                        ? (plan['yearly_price'] != null ? '/year' : '/mo')
                        : '/mo';

                    final currentSub = mySubAsync.value;
                    
                    final isCurrentPlan = currentSub != null && 
                        currentSub['plan_type'].toString().toUpperCase() == plan['plan_type'].toString().toUpperCase() &&
                        currentSub['status'].toString().toUpperCase() == 'ACTIVE';
                    
                    String cta = plan['cta'] ?? (plan['plan_type'] == 'ENTERPRISE' ? 'Contact Sales' : 'Get Started');
                    
                    if (isCurrentPlan) {
                      cta = 'Current Plan';
                    } else if (currentSub != null && plan['plan_type'] != 'ENTERPRISE') {
                      cta = 'Upgrade';
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: _buildPlanCard(
                        theme: theme,
                        title: plan['name'],
                        price: price,
                        period: period,
                        desc: plan['description'] ?? '',
                        features: List<String>.from(plan['features'] ?? []),
                        isPremium: plan['popular'] ?? false,
                        showDiscount: plan['show_discount'] ?? true,
                        cta: cta,
                        onPressed: isCurrentPlan ? null : () => _handleGetStarted(plan),
                      ),
                    ).animate().fadeIn(delay: (600 + index * 100).ms, duration: 600.ms).slideY(begin: 0.1, end: 0);
                  }),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleItem(String label, bool isActive) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => setState(() => _isAnnual = label.startsWith('Ann') || label.contains('(-20%)')),
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
    required bool showDiscount,
    required String cta,
    VoidCallback? onPressed,
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
                if (showDiscount && _isAnnual && title.toUpperCase().contains('PROFESSIONAL'))
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.extension<CustomColors>()!.success!.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Best Value',
                      style: TextStyle(
                        color: theme.extension<CustomColors>()!.success!,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else if (isPremium)
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

    if (plan['plan_type'] == 'STARTER') {
      if (mounted) context.go('/dashboard');
      return;
    }

    if (plan['plan_type'] == 'ENTERPRISE') {
      if (mounted) context.push('/contact');
      return;
    }

    if (mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) => MpesaPaymentModal(
          plan: plan,
          isAnnual: _isAnnual,
        ),
      );
    }
  }

}

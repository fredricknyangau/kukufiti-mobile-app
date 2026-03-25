import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:lucide_icons/lucide_icons.dart';

class BenefitsCarouselScreen extends StatefulWidget {
  const BenefitsCarouselScreen({super.key});

  @override
  State<BenefitsCarouselScreen> createState() => _BenefitsCarouselScreenState();
}

class _BenefitsCarouselScreenState extends State<BenefitsCarouselScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<BenefitData> _benefits = [
    BenefitData(
      icon: LucideIcons.activity,
      headline: 'Know Every Bird\'s Progress',
      body: 'Log daily weights and mortality rates to stay ahead of your harvest targets.',
    ),
    BenefitData(
      icon: LucideIcons.coins,
      headline: 'Cut Feed Waste, Boost Margins',
      body: 'Track feed consumption per batch and get cost-per-bird insights automatically.',
    ),
    BenefitData(
      icon: LucideIcons.trendingUp,
      headline: 'Plan Your Harvest With Confidence',
      body: 'Predict optimal slaughter dates and estimated revenue before the cycle ends.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ─── PROGRESS BAR ───
            LinearProgressIndicator(
              value: 0.50, // Step 2 of Onboarding
              backgroundColor: theme.colorScheme.outline,
              color: theme.colorScheme.primary,
              minHeight: 2,
            ),

            // ─── TOP BAR (SKIP) ───
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 8, right: 16),
                child: TextButton(
                  onPressed: () => context.go('/register'),
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

            // ─── CAROUSEL PAGEVIEW ───
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _benefits.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final item = _benefits[index];
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icon
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              item.icon,
                              size: 48,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 40),
                          // Headline
                          Text(
                            item.headline,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          // Body
                          Text(
                            item.body,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  // Close Page Container
                  );
                },
              ),
            ),

            // ─── BOTTOM CONTROLS ───
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _benefits.length,
                    effect: ExpandingDotsEffect(
                      dotHeight: 8,
                      dotWidth: 8,
                      activeDotColor: theme.colorScheme.primary,
                      dotColor: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 56,
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        if (_currentPage < _benefits.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          context.go('/register');
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        _currentPage == _benefits.length - 1 ? 'Start setup' : 'Next',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BenefitData {
  final IconData icon;
  final String headline;
  final String body;

  BenefitData({
    required this.icon,
    required this.headline,
    required this.body,
  });
}

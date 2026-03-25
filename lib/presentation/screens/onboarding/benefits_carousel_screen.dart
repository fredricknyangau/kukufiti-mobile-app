import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/public_mesh_background.dart';

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
      isHero: true,
      headline: 'Maximize Your\nFlock\'s Potential',
      body: 'Data-driven insights, biosecurity tracking, and automated accounting for modern farmers.',
    ),
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
      body: PublicMeshBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ─── PROGRESS BAR ───
              LinearProgressIndicator(
                value: 0.25 + (_currentPage * 0.25), // Step 1-4 of 4
                backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.2),
                color: theme.colorScheme.primary,
                minHeight: 2,
              ),

              // ─── TOP BAR (SKIP / LOGIN) ───
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            'assets/images/chicken_logo.jpeg',
                            width: 28,
                            height: 28,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'KukuFiti',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: theme.colorScheme.onSurface,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
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
                    
                    if (item.isHero) {
                      return _buildHeroSlide(context, item, theme);
                    }
                    
                    return _buildBenefitSlide(context, item, theme);
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
                        dotHeight: 6,
                        dotWidth: 6,
                        activeDotColor: theme.colorScheme.primary,
                        dotColor: theme.colorScheme.outline.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 56,
                      width: double.infinity,
                      child: CustomButton(
                        text: _currentPage == _benefits.length - 1 ? 'Get Started' : 'Continue',
                        onPressed: () {
                          if (_currentPage < _benefits.length - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOutCubic,
                            );
                          } else {
                            context.go('/register');
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSlide(BuildContext context, BenefitData item, ThemeData theme) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Hero Tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.sparkles, size: 12, color: theme.colorScheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    'SMART POULTRY APP',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
            
            const SizedBox(height: 24),
            
            // Headline
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                  color: theme.colorScheme.onSurface,
                ),
                children: [
                  const TextSpan(text: 'Maximize Your\n'),
                  TextSpan(
                    text: 'Flock\'s Potential',
                    style: TextStyle(color: theme.colorScheme.primary),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 800.ms).slideY(begin: 0.1, end: 0),
            
            const SizedBox(height: 16),
            
            // Body
            Text(
              item.body,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 400.ms, duration: 800.ms),
            
            const SizedBox(height: 48),
            
            // CTA Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.2,
              children: [
                _buildPublicCTA(context, 'Features', LucideIcons.layoutGrid, '/features', theme),
                _buildPublicCTA(context, 'Pricing', LucideIcons.tags, '/pricing', theme),
                _buildPublicCTA(context, 'About Us', LucideIcons.info, '/about', theme),
                _buildPublicCTA(context, 'Contact', LucideIcons.phone, '/contact', theme),
              ],
            ).animate().fadeIn(delay: 600.ms, duration: 800.ms).scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitSlide(BuildContext context, BenefitData item, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with glass effect
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
              ),
            ),
            child: Icon(
              item.icon,
              size: 56,
              color: theme.colorScheme.primary,
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack).shimmer(delay: 800.ms, duration: 1.5.seconds),
          
          const SizedBox(height: 48),
          
          // Headline
          Text(
            item.headline,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
          
          const SizedBox(height: 20),
          
          // Body
          Text(
            item.body,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }

  Widget _buildPublicCTA(
    BuildContext context,
    String label,
    IconData icon,
    String route,
    ThemeData theme,
  ) {
    final isDark = theme.brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(route),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurface.withValues(
              alpha: isDark ? 0.04 : 0.02,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.onSurface.withValues(
                alpha: isDark ? 0.08 : 0.04,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BenefitData {
  final IconData? icon;
  final String headline;
  final String body;
  final bool isHero;

  BenefitData({
    this.icon,
    required this.headline,
    required this.body,
    this.isHero = false,
  });
}

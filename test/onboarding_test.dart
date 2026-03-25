import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/presentation/screens/onboarding/welcome_screen.dart';
import 'package:mobile/presentation/screens/onboarding/benefits_carousel_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

void main() {
  testWidgets('WelcomeScreen renders headline and CTAs', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: WelcomeScreen(),
      ),
    );

    // Verify Headline
    expect(find.text('Run Your Farm.\nGrow Your Profit.'), findsOneWidget);

    // Verify Primary CTA
    expect(find.text('Get Started'), findsOneWidget);

    // Verify Ghost CTA
    expect(find.text('I already have an account'), findsOneWidget);
  });

  testWidgets('BenefitsCarouselScreen renders PageView and Skip button', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: BenefitsCarouselScreen(),
      ),
    );

    // Verify Skip button
    expect(find.text('Skip'), findsOneWidget);

    // Verify SmoothPageIndicator existence
    expect(find.byType(SmoothPageIndicator), findsOneWidget);

    // Verify first slide content
    expect(find.text('Know Every Bird\'s Progress'), findsOneWidget);
  });
}

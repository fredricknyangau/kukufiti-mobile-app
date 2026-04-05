import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';

// Public
import '../../presentation/screens/public/features_screen.dart';
import '../../presentation/screens/public/pricing_screen.dart';
import '../../presentation/screens/public/about_screen.dart';
import '../../presentation/screens/public/contact_screen.dart';

// Onboarding
import '../../presentation/screens/onboarding/benefits_carousel_screen.dart';

// Auth
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/auth/otp_verification_screen.dart';
import '../../presentation/screens/auth/profile_setup_screen.dart';
import '../../presentation/screens/public/splash_screen.dart';
import '../../presentation/screens/main_layout_screen.dart';
import '../../features/settings_management/presentation/screens/terms_screen.dart';


// Features / Dashboard
import '../../presentation/screens/dashboard/dashboard_screen.dart';
// Flock
import '../../features/flock_management/presentation/screens/flocks_screen.dart';
import '../../features/flock_management/presentation/screens/batches_screen.dart';
import '../../features/flock_management/presentation/screens/batch_details_screen.dart';

// Operations
import '../../features/feed_management/presentation/screens/feed_screen.dart';
import '../../features/weight_management/presentation/screens/weight_screen.dart';
import '../../features/vaccinations_management/presentation/screens/vaccinations_screen.dart';
import '../../features/mortality_management/presentation/screens/mortality_screen.dart';
import '../../features/calendar_management/presentation/screens/calendar_screen.dart';
import '../../features/inventory_management/presentation/screens/inventory_screen.dart';
import '../../features/reports_management/presentation/screens/reports_screen.dart';
import '../../features/feed_management/presentation/screens/feed_calculator_screen.dart';

import '../../features/ai_insights/presentation/screens/feed_advisory_screen.dart';
import '../../features/ai_insights/presentation/screens/mortality_analysis_screen.dart';
import '../../features/ai_insights/presentation/screens/ai_advisory_hub_screen.dart';
import '../../features/ai_insights/presentation/screens/harvest_prediction_screen.dart';
import '../../features/ai_insights/presentation/screens/disease_risk_screen.dart';
import '../../features/ai_insights/presentation/screens/fcr_insights_screen.dart';
import '../../features/ai_insights/presentation/screens/ai_chat_screen.dart';
import '../../features/ai_insights/presentation/screens/voice_observation_screen.dart';
import '../../features/ai_insights/presentation/screens/harvest_optimization_screen.dart';
import '../../presentation/screens/features/daily_checks_screen.dart';
import '../../presentation/screens/features/tasks_screen.dart';

// Financials
import '../../features/expenses_management/presentation/screens/financials_screen.dart';
import '../../features/expenses_management/presentation/screens/expenditures_screen.dart';
import '../../features/sales_management/presentation/screens/sales_screen.dart';
import '../../features/market_management/presentation/screens/market_screen.dart';
import '../../features/analytics_management/presentation/screens/analytics_screen.dart';

// Business / Management
import '../../features/settings_management/presentation/screens/settings_screen.dart';
import '../../features/profile_management/presentation/screens/profile_screen.dart';
import '../../features/people_management/presentation/screens/people_screen.dart';
import '../../features/biosecurity_management/presentation/screens/biosecurity_screen.dart';
import '../../features/vet_management/presentation/screens/vet_screen.dart';
import '../../features/resources_management/presentation/screens/resources_screen.dart';
import '../../features/alerts_management/presentation/screens/alerts_screen.dart';

// Admin
import '../../features/admin_dashboard_management/presentation/screens/admin_dashboard_screen.dart';
import '../../features/audit_logs_management/presentation/screens/audit_logs_screen.dart';
import '../../features/admin_dashboard_management/presentation/screens/manage_resources_screen.dart';
import '../../features/admin_dashboard_management/presentation/screens/manage_users_screen.dart';

// Farm Management
import '../../features/farm_management/presentation/screens/farms_screen.dart';
import 'package:mobile/features/community_management/presentation/screens/community_feed_screen.dart';
import 'package:mobile/features/community_management/presentation/screens/post_detail_screen.dart';
import 'package:mobile/features/community_management/presentation/screens/create_post_screen.dart';



class _RouterRefreshListenable extends ChangeNotifier {
  _RouterRefreshListenable(Ref ref) {
    ref.listen(authProvider, (previous, next) {
      notifyListeners();
    });
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final listenable = _RouterRefreshListenable(ref);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: listenable,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      if (authState.isLoading) return null; // Wait for token initialization

      final isAuthenticated = authState.isAuthenticated;

      final isAuthPath = state.uri.path == '/login' || 
                        state.uri.path == '/register' || 
                        state.uri.path == '/otp-verify';
                        
      final isPublicPath = state.uri.path == '/' || 
                          state.uri.path == '/welcome' ||
                          state.uri.path == '/benefits-carousel' ||
                          state.uri.path == '/features' || 
                          state.uri.path == '/pricing' ||
                          state.uri.path == '/about' ||
                          state.uri.path == '/contact' ||
                          state.uri.path == '/terms';

      if (isAuthenticated) {
        debugPrint('Router: Authenticated user on path: ${state.uri.path}');
        // Only redirect to dashboard if on primary login/register screens
        // and NOT on otp-verify (which needs to handle its own navigation to profile-setup)
        if (state.uri.path == '/login' || state.uri.path == '/register') {
          debugPrint('Router: Redirecting to /dashboard (Auth Entry Point)');
          return '/dashboard';
        }
        // Allow /otp-verify and /profile-setup to stay
        return null;
      }

      // Unauthenticated
      if (!isAuthPath && !isPublicPath) {
        return '/login';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const BenefitsCarouselScreen(),
      ),
      GoRoute(
        path: '/benefits-carousel',
        builder: (context, state) => const BenefitsCarouselScreen(),
      ),
      GoRoute(
        path: '/features',
        builder: (context, state) => const FeaturesScreen(),
      ),
      GoRoute(
        path: '/pricing',
        builder: (context, state) => const PricingScreen(),
      ),
      GoRoute(
        path: '/about',
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: '/contact',
        builder: (context, state) => const ContactScreen(),
      ),
      GoRoute(
        path: '/terms',
        builder: (context, state) => const TermsScreen(),
      ),

      // Auth Routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/otp-verify',
        builder: (context, state) {
          final phone = state.uri.queryParameters['phone'] ?? '';
          return OtpVerificationScreen(phoneNumber: phone);
        },
      ),
      GoRoute(
        path: '/profile-setup',
        builder: (context, state) => const ProfileSetupScreen(),
      ),

      // Protected App Routes (Stateful Shell Route)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainLayoutScreen(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Home / Dashboard
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
              GoRoute(
                path: '/inventory',
                builder: (context, state) => const InventoryScreen(),
              ),
              GoRoute(
                path: '/financials',
                builder: (context, state) => const FinancialsScreen(),
              ),
              GoRoute(
                path: '/reports',
                builder: (context, state) => const ReportsScreen(),
              ),
              // Added Operations
              GoRoute(
                path: '/feed',
                builder: (context, state) => const FeedScreen(),
              ),
              GoRoute(
                path: '/feed-calculator',
                builder: (context, state) => const FeedCalculatorScreen(),
              ),
              GoRoute(
                path: '/weight',
                builder: (context, state) => const WeightScreen(),
              ),
              GoRoute(
                path: '/vaccinations',
                builder: (context, state) => const VaccinationsScreen(),
              ),
              GoRoute(
                path: '/mortality',
                builder: (context, state) => const MortalityScreen(),
              ),
              GoRoute(
                path: '/calendar',
                builder: (context, state) => const CalendarScreen(),
              ),
              GoRoute(
                path: '/daily-checks',
                builder: (context, state) => const DailyChecksScreen(),
              ),
              GoRoute(
                path: '/tasks',
                builder: (context, state) => const TasksScreen(),
              ),
              GoRoute(
                path: '/community',
                builder: (context, state) => const CommunityFeedScreen(),
              ),
              GoRoute(
                path: '/community/post',
                builder: (context, state) {
                   final id = state.extra as String? ?? '';
                   return PostDetailScreen(postId: id);
                },
              ),
              GoRoute(
                path: '/community/create',
                builder: (context, state) => const CreatePostScreen(),
              ),
            ],
          ),
          
          // Branch 1: Batches
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/batches',
                builder: (context, state) => const BatchesScreen(),
              ),
              GoRoute(
                path: '/flocks',
                builder: (context, state) => const FlocksScreen(),
              ),
              GoRoute(
                path: '/batch/:id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return BatchDetailsScreen(batchId: id);
                },
              ),
            ],
          ),

          // Branch 2: AI Advisory
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/ai-insights-hub',
                builder: (context, state) => const AiAdvisoryHubScreen(),
              ),
              GoRoute(
                path: '/ai-feed-advisory',
                builder: (context, state) => const FeedAdvisoryScreen(),
              ),
              GoRoute(
                path: '/ai-mortality-analysis',
                builder: (context, state) => const MortalityAdvisoryScreen(),
              ),
              GoRoute(
                path: '/ai-harvest-prediction',
                builder: (context, state) => const HarvestPredictionScreen(),
              ),
              GoRoute(
                path: '/ai-disease-risk',
                builder: (context, state) => const DiseaseRiskScreen(),
              ),
              GoRoute(
                path: '/ai-fcr-insights',
                builder: (context, state) => const FcrInsightsScreen(),
              ),
              GoRoute(
                path: '/ai-chat',
                builder: (context, state) => const AiChatScreen(),
              ),
              GoRoute(
                path: '/ai-voice-observation',
                builder: (context, state) => const VoiceObservationScreen(),
              ),
              GoRoute(
                path: '/ai-profit-optimizer',
                builder: (context, state) => const HarvestOptimizationScreen(),
              ),
            ],
          ),

          // Branch 3: Analytics / Finance
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/analytics',
                builder: (context, state) => const AnalyticsScreen(),
              ),
              GoRoute(
                path: '/expenditures',
                builder: (context, state) => const ExpendituresScreen(),
              ),
              GoRoute(
                path: '/sales',
                builder: (context, state) => const SalesScreen(),
              ),
              GoRoute(
                path: '/market',
                builder: (context, state) => const MarketScreen(),
              ),
            ],
          ),

          // Branch 4: Settings / Admin
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
              GoRoute(
                path: '/farms',
                builder: (context, state) => const FarmsScreen(),
              ),
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
              GoRoute(
                path: '/people',
                builder: (context, state) => const PeopleScreen(),
              ),
              GoRoute(
                path: '/biosecurity',
                builder: (context, state) => const BiosecurityScreen(),
              ),
              GoRoute(
                path: '/vet',
                builder: (context, state) => const VetScreen(),
              ),
              GoRoute(
                path: '/resources',
                builder: (context, state) => const ResourcesScreen(),
              ),
              GoRoute(
                path: '/alerts',
                builder: (context, state) => const AlertsScreen(),
              ),
              GoRoute(
                path: '/admin',
                builder: (context, state) => const AdminDashboardScreen(),
              ),
              GoRoute(
                path: '/manage-resources',
                builder: (context, state) => const ManageResourcesScreen(),
              ),
              GoRoute(
                path: '/manage-users',
                builder: (context, state) => const ManageUsersScreen(),
              ),

              GoRoute(
                path: '/audit-logs',
                builder: (context, state) => const AuditLogsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

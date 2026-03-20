import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';

// Public
import '../../presentation/screens/public/landing_screen.dart';
import '../../presentation/screens/public/features_screen.dart';
import '../../presentation/screens/public/pricing_screen.dart';
import '../../presentation/screens/public/about_screen.dart';
import '../../presentation/screens/public/contact_screen.dart';

// Auth
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';

// Layout
import '../../presentation/screens/main_layout_screen.dart';

// Features / Dashboard
import '../../presentation/screens/dashboard/dashboard_screen.dart';
import '../../features/admin_dashboard_management/presentation/screens/admin_dashboard_screen.dart';
import '../../features/alerts_management/presentation/screens/alerts_screen.dart';
import '../../features/analytics_management/presentation/screens/analytics_screen.dart';
import '../../features/audit_logs_management/presentation/screens/audit_logs_screen.dart';
import '../../features/flock_management/presentation/screens/batches_screen.dart';
import '../../features/biosecurity_management/presentation/screens/biosecurity_screen.dart';
import '../../features/calendar_management/presentation/screens/calendar_screen.dart';
import '../../features/expenses_management/presentation/screens/expenditures_screen.dart';
import '../../features/feed_management/presentation/screens/feed_screen.dart';
import '../../features/inventory_management/presentation/screens/inventory_screen.dart';
import '../../features/market_management/presentation/screens/market_screen.dart';
import '../../features/mortality_management/presentation/screens/mortality_screen.dart';
import '../../features/people_management/presentation/screens/people_screen.dart';
import '../../features/profile_management/presentation/screens/profile_screen.dart';
import '../../features/reports_management/presentation/screens/reports_screen.dart';
import '../../features/resources_management/presentation/screens/resources_screen.dart';
import '../../features/sales_management/presentation/screens/sales_screen.dart';
import '../../features/settings_management/presentation/screens/settings_screen.dart';
import '../../features/vaccinations_management/presentation/screens/vaccinations_screen.dart';
import '../../features/vet_management/presentation/screens/vet_screen.dart';
import '../../features/weight_management/presentation/screens/weight_screen.dart';
import '../../presentation/screens/features/not_found_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final isAuthenticated = ref.watch(authProvider.select((s) => s.isAuthenticated));

  return GoRouter(
    initialLocation: '/',
    refreshListenable: AuthRefreshListenable(ref),
    errorBuilder: (context, state) => const NotFoundScreen(),
    redirect: (context, state) {
      final isLoggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/register';
      final isPublic = state.matchedLocation == '/' || 
                       state.matchedLocation == '/features' || 
                       state.matchedLocation == '/pricing' ||
                       state.matchedLocation == '/about' ||
                       state.matchedLocation == '/contact';

      if (!isAuthenticated) {
        if (!isLoggingIn && !isPublic) return '/login';
      } else {
        if (isLoggingIn || state.matchedLocation == '/') return '/dashboard';
      }
      return null;
    },
    routes: [
      // Public Routes with Fade Transitions
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LandingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      ),
      GoRoute(
        path: '/features',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const FeaturesScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      ),
      GoRoute(
        path: '/pricing',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const PricingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              SlideTransition(
                position: animation.drive(
                  Tween(begin: const Offset(0, 1), end: Offset.zero)
                      .chain(CurveTween(curve: Curves.easeOutCubic)),
                ),
                child: child,
              ),
        ),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const RegisterScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              SlideTransition(
                position: animation.drive(
                  Tween(begin: const Offset(1, 0), end: Offset.zero)
                      .chain(CurveTween(curve: Curves.easeOutCubic)),
                ),
                child: child,
              ),
        ),
      ),

      // Main App Layout (Shell)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => MainLayoutScreen(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
              )
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/batches',
                builder: (context, state) => const BatchesScreen(),
              )
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/analytics',
                builder: (context, state) => const AnalyticsScreen(),
              )
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              )
            ],
          ),
        ],
      ),
      
      // Feature Routes with Slide Transitions
      GoRoute(
        path: '/people',
        pageBuilder: (context, state) => _slidePage(state, const PeopleScreen()),
      ),
      GoRoute(
        path: '/calendar',
        pageBuilder: (context, state) => _slidePage(state, const CalendarScreen()),
      ),
      GoRoute(
        path: '/profile',
        pageBuilder: (context, state) => _slidePage(state, const ProfileScreen()),
      ),
      GoRoute(
        path: '/admin',
        pageBuilder: (context, state) => _slidePage(state, const AdminDashboardScreen()),
      ),
      GoRoute(
        path: '/audit-logs',
        pageBuilder: (context, state) => _slidePage(state, const AuditLogsScreen()),
      ),
      GoRoute(
        path: '/mortality',
        pageBuilder: (context, state) => _slidePage(state, const MortalityScreen()),
      ),
      GoRoute(
        path: '/expenditures',
        pageBuilder: (context, state) => _slidePage(state, const ExpendituresScreen()),
      ),
      GoRoute(
        path: '/vaccinations',
        pageBuilder: (context, state) => _slidePage(state, const VaccinationsScreen()),
      ),
      GoRoute(
        path: '/sales',
        pageBuilder: (context, state) => _slidePage(state, const SalesScreen()),
      ),
      GoRoute(
        path: '/feed',
        pageBuilder: (context, state) => _slidePage(state, const FeedScreen()),
      ),
      GoRoute(
        path: '/weight',
        pageBuilder: (context, state) => _slidePage(state, const WeightScreen()),
      ),
      GoRoute(
        path: '/inventory',
        pageBuilder: (context, state) => _slidePage(state, const InventoryScreen()),
      ),
      GoRoute(
        path: '/biosecurity',
        pageBuilder: (context, state) => _slidePage(state, const BiosecurityScreen()),
      ),
      GoRoute(
        path: '/reports',
        pageBuilder: (context, state) => _slidePage(state, const ReportsScreen()),
      ),
      GoRoute(
        path: '/market',
        pageBuilder: (context, state) => _slidePage(state, const MarketScreen()),
      ),
      GoRoute(
        path: '/vet',
        pageBuilder: (context, state) => _slidePage(state, const VetScreen()),
      ),
      GoRoute(
        path: '/alerts',
        pageBuilder: (context, state) => _slidePage(state, const AlertsScreen()),
      ),
      GoRoute(
        path: '/resources',
        pageBuilder: (context, state) => _slidePage(state, const ResourcesScreen()),
      ),
    ],
  );
});

CustomTransitionPage _slidePage(GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: animation.drive(
          Tween(begin: const Offset(1, 0), end: Offset.zero)
              .chain(CurveTween(curve: Curves.easeOutCubic)),
        ),
        child: child,
      );
    },
  );
}

class AuthRefreshListenable extends ChangeNotifier {
  AuthRefreshListenable(Ref ref) {
    ref.listen(authProvider.select((s) => s.isAuthenticated), (_, __) => notifyListeners());
  }
}

class AppRouter {
  static GoRouter get router => throw UnimplementedError('Use routerProvider instead');
}

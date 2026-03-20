import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';

// Public
import '../../presentation/screens/public/landing_screen.dart';
import '../../presentation/screens/public/features_screen.dart';
import '../../presentation/screens/public/pricing_screen.dart';

// Auth
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';

// Layout
import '../../presentation/screens/main_layout_screen.dart';

// Features / Dashboard
import '../../presentation/screens/dashboard/dashboard_screen.dart';
import '../../features/flock_management/presentation/screens/flocks_screen.dart';
import '../../features/flock_management/presentation/screens/batches_screen.dart';
import '../../features/flock_management/presentation/screens/batch_details_screen.dart';
import '../../features/inventory_management/presentation/screens/inventory_screen.dart';
import '../../features/expenses_management/presentation/screens/financials_screen.dart';
import '../../features/reports_management/presentation/screens/reports_screen.dart';
import '../../features/settings_management/presentation/screens/settings_screen.dart';
import '../../features/profile_management/presentation/screens/profile_screen.dart';
import '../../features/analytics_management/presentation/screens/analytics_screen.dart';

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
      final isAuthenticated = authState.isAuthenticated;
      final isAuthPath = state.uri.path == '/login' || state.uri.path == '/register';
      final isPublicPath = state.uri.path == '/' || 
                          state.uri.path == '/features' || 
                          state.uri.path == '/pricing';

      if (!isAuthenticated && !isAuthPath && !isPublicPath) {
        return '/login';
      }

      if (isAuthenticated && isAuthPath) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      // Public Routes
      GoRoute(
        path: '/',
        builder: (context, state) => const LandingScreen(),
      ),
      GoRoute(
        path: '/features',
        builder: (context, state) => const FeaturesScreen(),
      ),
      GoRoute(
        path: '/pricing',
        builder: (context, state) => const PricingScreen(),
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

          // Branch 2: Analytics
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/analytics',
                builder: (context, state) => const AnalyticsScreen(),
              ),
            ],
          ),

          // Branch 3: Settings
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

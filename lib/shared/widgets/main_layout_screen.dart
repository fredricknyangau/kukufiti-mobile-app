import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mobile/core/security/biometric_service.dart';
import 'package:mobile/features/settings_management/presentation/controllers/settings_controller.dart';
import 'package:mobile/features/billing_management/presentation/providers/billing_providers.dart';
import 'package:mobile/features/profile_management/presentation/providers/user_providers.dart';
import 'package:mobile/shared/widgets/premium_upgrade_dialog.dart';

class MainLayoutScreen extends ConsumerStatefulWidget {
  const MainLayoutScreen({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends ConsumerState<MainLayoutScreen> with WidgetsBindingObserver {
  bool _isUnlocked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Auto-trigger auth on load if enabled
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAuthOnLoad());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Re-lock when app goes to background
      final settings = ref.read(settingsProvider);
      if (settings.biometricLockEnabled) {
        setState(() {
          _isUnlocked = false;
        });
      }
    } else if (state == AppLifecycleState.resumed) {
      _checkAuthOnLoad();
    }
  }

  void _checkAuthOnLoad() async {
    final settings = ref.read(settingsProvider);
    if (settings.biometricLockEnabled && !_isUnlocked) {
      final success = await BiometricService.authenticate();
      if (success) {
        setState(() {
          _isUnlocked = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final subAsync = ref.watch(subscriptionProvider);
    final settings = ref.watch(settingsProvider);
    final profile = ref.watch(profileProvider).value;
    final plan = subAsync.value?['plan_type'] ?? 'STARTER';
    final isStarter = profile?.isAdmin != true && plan == 'STARTER';
    
    final isLocked = settings.biometricLockEnabled && !_isUnlocked;

    void goBranch(int index) {
      if (index == 3 && isStarter) {
        showPremiumUpgradeDialog(context, 'Analytics & Custom Reports');
        return;
      }
      widget.navigationShell.goBranch(
        index,
        initialLocation: index == widget.navigationShell.currentIndex,
      );
    }

    return PopScope(
      canPop: widget.navigationShell.currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (widget.navigationShell.currentIndex != 0) {
          widget.navigationShell.goBranch(0);
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            widget.navigationShell,
            if (isLocked)
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
                          Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              LucideIcons.shieldAlert,
                              color: Theme.of(context).colorScheme.primary,
                              size: 48,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'KUKU FITI SECURED',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              letterSpacing: 2.0,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Authentication Required',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please verify your identity to access farm records',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 48),
                          SizedBox(
                            width: 200,
                            height: 56,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: _checkAuthOnLoad,
                              icon: const Icon(LucideIcons.fingerprint),
                              label: const Text(
                                'UNLOCK NOW',
                                style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.1),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        bottomNavigationBar: isLocked 
          ? null 
          : NavigationBar(
              selectedIndex: widget.navigationShell.currentIndex,
              onDestinationSelected: goBranch,
              destinations: [
                const NavigationDestination(
                   icon: Icon(LucideIcons.home),
                   label: 'Home',
                ),
                const NavigationDestination(
                   icon: Icon(LucideIcons.layers),
                   label: 'Batches',
                ),
                const NavigationDestination(
                   icon: Icon(LucideIcons.sparkles),
                   label: 'AI Advisory',
                ),
                NavigationDestination(
                   icon: const Icon(LucideIcons.pieChart),
                   label: isStarter ? 'Analytics' : 'Analytics',
                ),
                const NavigationDestination(
                   icon: Icon(LucideIcons.settings),
                   label: 'Settings',
                ),
              ],
            ),
      ),
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/security/biometric_service.dart';
import '../../features/settings_management/presentation/controllers/settings_controller.dart';
import '../../providers/data_providers.dart';
import '../widgets/premium_upgrade_dialog.dart';

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
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.8),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              LucideIcons.lock,
                              color: Theme.of(context).colorScheme.primary,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Kuku Fiti is Locked',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Authenticate to continue',
                            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.7)),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            onPressed: _checkAuthOnLoad,
                            icon: const Icon(LucideIcons.shieldCheck),
                            label: const Text('Unlock'),
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


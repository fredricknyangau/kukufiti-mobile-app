import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:go_router/go_router.dart';
import 'package:mobile/core/config/app_config.dart';
import 'package:mobile/core/storage/secure_storage_service.dart';
import 'package:mobile/core/services/biometric_service.dart';
import 'package:mobile/features/settings_management/presentation/controllers/settings_controller.dart';
import 'package:mobile/shared/widgets/app_drawer.dart';
import 'package:mobile/shared/widgets/custom_card.dart';
import 'package:mobile/shared/providers/data_providers.dart';
import 'package:mobile/app/theme/app_theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final userAsync = ref.watch(profileProvider);
    final subscriptionAsync = ref.watch(subscriptionProvider);
    final theme = Theme.of(context);

    // Helper map for titles
    String getThemeModeTitle(ThemeMode mode) {
      switch (mode) {
        case ThemeMode.light:
          return 'Light';
        case ThemeMode.dark:
          return 'Dark';
        case ThemeMode.system:
          return 'System Default';
      }
    }

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileCard(context, ref, theme, userAsync.value, subscriptionAsync.value),
          const SizedBox(height: 24),
          _buildSettingsSection(
            'Appearance',
            [
              ListTile(
                leading: const Icon(LucideIcons.sun),
                title: const Text('Theme Mode'),
                subtitle: Text(getThemeModeTitle(settings.themeMode)),
                trailing: const Icon(LucideIcons.chevronRight),
                onTap: () {
                  _showThemeDialog(context, settings.themeMode, notifier);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSettingsSection(
            'Regional Preferences',
            [
              ListTile(
                leading: const Icon(LucideIcons.coins),
                title: const Text('Currency'),
                subtitle: Text(settings.currency),
                trailing: const Icon(LucideIcons.chevronRight),
                onTap: () {
                  _showCurrencyDialog(context, settings.currency, notifier);
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.globe),
                title: const Text('Language'),
                subtitle: Text(settings.language == 'en' ? 'English' : 'Swahili'),
                trailing: const Icon(LucideIcons.chevronRight),
                onTap: () {
                  _showLanguageDialog(context, settings.language, notifier);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSettingsSection(
            'Notifications',
            [
              ListTile(
                leading: const Icon(LucideIcons.bell),
                title: const Text('Push Notifications'),
                trailing: Switch(
                  value: settings.pushNotificationsEnabled,
                  onChanged: (v) => notifier.setPushNotifications(v),
                ),
              ),
              ListTile(
                leading: const Icon(LucideIcons.mail),
                title: const Text('Email Summaries'),
                trailing: Switch(
                  value: settings.emailSummariesEnabled,
                  onChanged: (v) => notifier.setEmailSummaries(v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Security Section with Biometric Hardware Check
          ref.watch(biometricSupportProvider).when(
                data: (isSupported) => isSupported
                    ? Column(
                        children: [
                          _buildSettingsSection(
                            'Security',
                            [
                              ListTile(
                                leading: const Icon(LucideIcons.lock),
                                title: const Text('Biometric App Lock'),
                                subtitle: const Text('Require fingerprint or FaceID to open'),
                                trailing: Switch(
                                  value: settings.biometricLockEnabled,
                                  onChanged: (v) async {
                                    if (v) {
                                      // Verification step: confirm they have access now
                                      final authenticated = await BiometricService.authenticate();
                                      if (authenticated) {
                                        notifier.setBiometricLock(true);
                                      } else {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Authentication failed. Biometric lock not enabled.')),
                                          );
                                        }
                                      }
                                    } else {
                                      notifier.setBiometricLock(false);
                                    }
                                  },
                                ),
                              ),
                              ListTile(
                                leading: const Icon(LucideIcons.key),
                                title: const Text('App PIN Lock'),
                                subtitle: const Text('Use a 4-digit PIN as fallback'),
                                trailing: Switch(
                                  value: settings.pinLockEnabled,
                                  onChanged: (v) async {
                                    if (v) {
                                      final existingPin = await SecureStorageService.getAppPin();
                                      if (existingPin == null) {
                                        if (context.mounted) _showPinSetupDialog(context, notifier);
                                      } else {
                                        notifier.setPinLock(true);
                                      }
                                    } else {
                                      notifier.setPinLock(false);
                                    }
                                  },
                                ),
                                onTap: settings.pinLockEnabled ? () => _showPinSetupDialog(context, notifier) : null,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],
                      )
                    : _buildSettingsSection(
                        'Security',
                        [
                          ListTile(
                            leading: const Icon(LucideIcons.key),
                            title: const Text('App PIN Lock'),
                            subtitle: const Text('Protect app with a 4-digit PIN'),
                            trailing: Switch(
                              value: settings.pinLockEnabled,
                              onChanged: (v) async {
                                if (v) {
                                  final existingPin = await SecureStorageService.getAppPin();
                                  if (existingPin == null) {
                                    if (context.mounted) _showPinSetupDialog(context, notifier);
                                  } else {
                                    notifier.setPinLock(true);
                                  }
                                } else {
                                  notifier.setPinLock(false);
                                }
                              },
                            ),
                            onTap: settings.pinLockEnabled ? () => _showPinSetupDialog(context, notifier) : null,
                          ),
                        ],
                      ),
                loading: () => const SizedBox.shrink(),
                error: (err, stack) => const SizedBox.shrink(),
              ),
          const SizedBox(height: 24),
          _buildSettingsSection(
            'Support & Legal',
            [
              ListTile(
                leading: const Icon(LucideIcons.helpCircle),
                title: const Text('Help & Support'),
                subtitle: const Text('FAQs and contact support'),
                trailing: const Icon(LucideIcons.chevronRight),
                onTap: () => context.push('/contact'),
              ),
              ListTile(
                leading: const Icon(LucideIcons.fileText),
                title: const Text('Terms of Service'),
                trailing: const Icon(LucideIcons.chevronRight),
                onTap: () => context.push('/terms'),
              ),
              ListTile(
                leading: const Icon(LucideIcons.shieldCheck),
                title: const Text('Privacy Policy'),
                trailing: const Icon(LucideIcons.chevronRight),
                onTap: () {
                  // Reuse terms screen or add dedicated one later
                  context.push('/terms');
                },
              ),
            ],
          ),
          if (userAsync.value != null && (userAsync.value!.isSuperuser == true || userAsync.value!.role == 'ADMIN')) ...[
            const SizedBox(height: 24),
            _buildSettingsSection(
              'Admin Controls',
              [
                ListTile(
                  leading: const Icon(LucideIcons.shield),
                  title: const Text('Admin Dashboard'),
                  trailing: const Icon(LucideIcons.chevronRight),
                  onTap: () => context.push('/admin'),
                ),
                ListTile(
                  leading: const Icon(LucideIcons.clipboardList),
                  title: const Text('System Audit Logs'),
                  trailing: const Icon(LucideIcons.chevronRight),
                  onTap: () => context.push('/audit-logs'),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          _buildSettingsSection(
            'About',
            [
              ListTile(
                leading: const Icon(LucideIcons.info),
                title: const Text('Version'),
                subtitle: Text('Build Mode: ${AppConfig.buildMode.toUpperCase()}'),
                trailing: Text(
                  AppConfig.fullVersion,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPinSetupDialog(BuildContext context, SettingsNotifier notifier) {
    final pinController = TextEditingController();
    final confirmController = TextEditingController();
    bool isConfirming = false;
    String firstPin = '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isConfirming ? 'Confirm PIN' : 'Set App PIN', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(isConfirming ? 'Re-enter your 4-digit PIN' : 'Enter a 4-digit PIN to secure the app'),
              const SizedBox(height: 20),
              TextField(
                controller: isConfirming ? confirmController : pinController,
                autofocus: true,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, letterSpacing: 16, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  counterText: '',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  if (value.length == 4) {
                    if (!isConfirming) {
                      setState(() {
                        firstPin = value;
                        isConfirming = true;
                      });
                    } else {
                      if (value == firstPin) {
                        SecureStorageService.saveAppPin(value);
                        notifier.setPinLock(true);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('App PIN set successfully!')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('PINs do not match. Try again.')),
                        );
                        setState(() {
                          isConfirming = false;
                          pinController.clear();
                          confirmController.clear();
                        });
                      }
                    }
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        CustomCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard(
    BuildContext context, 
    WidgetRef ref, 
    ThemeData theme, 
    dynamic user, 
    dynamic sub,
  ) {
    final plan = sub?['plan_type'] ?? 'STARTER';
    final isPremium = plan != 'STARTER';
    final customColors = theme.extension<CustomColors>();
    final planColor = plan == 'ENTERPRISE' 
        ? (customColors?.purple ?? Colors.purple)
        : (plan == 'PROFESSIONAL' ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.4));

    return CustomCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.colorScheme.primary, theme.colorScheme.primary.withValues(alpha: 0.6)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    (user?.fullName ?? 'F')[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.fullName ?? 'Farmer',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? '',
                      style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: planColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: planColor.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            plan == 'ENTERPRISE' ? LucideIcons.gem : (isPremium ? LucideIcons.award : LucideIcons.user),
                            size: 12,
                            color: planColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            plan,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: planColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/profile'),
                  icon: const Icon(LucideIcons.user, size: 16),
                  label: const Text('Edit Profile'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.push('/pricing');
                  },
                  icon: Icon(isPremium ? LucideIcons.creditCard : LucideIcons.trendingUp, size: 16),
                  label: Text(isPremium ? 'Plan' : 'Upgrade'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.go('/welcome');
              }
            },
            icon: const Icon(LucideIcons.logOut, size: 16),
            label: const Text('Logout and Sign out'),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            ),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context, ThemeMode current, SettingsNotifier notifier) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('System Default'),
              trailing: current == ThemeMode.system ? Icon(Icons.check, color: theme.colorScheme.primary) : null,
              onTap: () {
                notifier.setThemeMode(ThemeMode.system);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Light'),
              trailing: current == ThemeMode.light ? Icon(Icons.check, color: theme.colorScheme.primary) : null,
              onTap: () {
                notifier.setThemeMode(ThemeMode.light);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Dark'),
              trailing: current == ThemeMode.dark ? Icon(Icons.check, color: theme.colorScheme.primary) : null,
              onTap: () {
                notifier.setThemeMode(ThemeMode.dark);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCurrencyDialog(BuildContext context, String current, SettingsNotifier notifier) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Currency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['KES', 'USD', 'EUR']
              .map((c) => ListTile(
                    title: Text(c),
                    trailing: current == c ? Icon(Icons.check, color: theme.colorScheme.primary) : null,
                    onTap: () {
                      notifier.setCurrency(c);
                      Navigator.pop(context);
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, String current, SettingsNotifier notifier) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              trailing: current == 'en' ? Icon(Icons.check, color: theme.colorScheme.primary) : null,
              onTap: () {
                notifier.setLanguage('en');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Swahili'),
              trailing: current == 'sw' ? Icon(Icons.check, color: theme.colorScheme.primary) : null,
              onTap: () {
                notifier.setLanguage('sw');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

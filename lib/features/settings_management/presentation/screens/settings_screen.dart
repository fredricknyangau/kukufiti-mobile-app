import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:mobile/features/settings_management/presentation/controllers/settings_controller.dart';
import 'package:mobile/shared/widgets/app_drawer.dart';
import 'package:mobile/shared/widgets/custom_card.dart';
import 'package:mobile/features/settings_management/presentation/screens/terms_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

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
          _buildSettingsSection(
            'Security',
            [
              ListTile(
                leading: const Icon(LucideIcons.lock),
                title: const Text('Biometric App Lock'),
                trailing: Switch(
                  value: settings.biometricLockEnabled,
                  onChanged: (v) => notifier.setBiometricLock(v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSettingsSection(
            'About',
            [
              ListTile(
                leading: const Icon(LucideIcons.info),
                title: const Text('Version'),
                trailing: const Text('1.2.4'),
              ),
              ListTile(
                leading: const Icon(LucideIcons.fileText),
                title: const Text('Terms of Service'),
                trailing: const Icon(LucideIcons.chevronRight),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TermsScreen()),
                  );
                },
              ),
            ],
          ),
        ],
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

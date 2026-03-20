import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/settings_state.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../data/repositories/settings_repository_impl.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl();
});

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    // Trigger async load, will update state when done
    _loadSettings();

    // Return temporary default state
    return SettingsState(
      themeMode: ThemeMode.system,
      currency: 'KES',
      language: 'en',
      pushNotificationsEnabled: true,
      emailSummariesEnabled: false,
    );
  }

  Future<void> _loadSettings() async {
    final repository = ref.read(settingsRepositoryProvider);
    final result = await repository.getSettings();
    result.fold(
      (failure) => null, // handle failure or leave defaults
      (settings) => state = settings,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    final repository = ref.read(settingsRepositoryProvider);
    await repository.setThemeMode(mode);
  }

  Future<void> setCurrency(String currency) async {
    state = state.copyWith(currency: currency);
    final repository = ref.read(settingsRepositoryProvider);
    await repository.setCurrency(currency);
  }

  Future<void> setLanguage(String language) async {
    state = state.copyWith(language: language);
    final repository = ref.read(settingsRepositoryProvider);
    await repository.setLanguage(language);
  }

  Future<void> setPushNotifications(bool enabled) async {
    state = state.copyWith(pushNotificationsEnabled: enabled);
    final repository = ref.read(settingsRepositoryProvider);
    await repository.setPushNotifications(enabled);
  }

  Future<void> setEmailSummaries(bool enabled) async {
    state = state.copyWith(emailSummariesEnabled: enabled);
    final repository = ref.read(settingsRepositoryProvider);
    await repository.setEmailSummaries(enabled);
  }
}


final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(() {
  return SettingsNotifier();
});

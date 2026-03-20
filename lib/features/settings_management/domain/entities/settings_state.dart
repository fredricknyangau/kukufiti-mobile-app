import 'package:flutter/material.dart';

class SettingsState {
  final ThemeMode themeMode;
  final String currency;
  final String language;
  final bool pushNotificationsEnabled;
  final bool emailSummariesEnabled;

  SettingsState({
    required this.themeMode,
    required this.currency,
    required this.language,
    this.pushNotificationsEnabled = true,
    this.emailSummariesEnabled = false,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    String? currency,
    String? language,
    bool? pushNotificationsEnabled,
    bool? emailSummariesEnabled,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      currency: currency ?? this.currency,
      language: language ?? this.language,
      pushNotificationsEnabled: pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      emailSummariesEnabled: emailSummariesEnabled ?? this.emailSummariesEnabled,
    );
  }
}


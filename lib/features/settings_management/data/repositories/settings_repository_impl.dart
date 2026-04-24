import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/api_endpoints.dart';
import 'package:mobile/features/settings_management/domain/entities/settings_state.dart';
import 'package:mobile/features/settings_management/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  static const String _themeKey = 'settings_theme_mode';
  static const String _currencyKey = 'settings_currency';
  static const String _languageKey = 'settings_language';
  static const String _pushNotificationsKey = 'settings_push_notifications';
  static const String _emailSummariesKey = 'settings_email_summaries';
  static const String _biometricLockKey = 'settings_biometric_lock';
  static const String _pinLockKey = 'settings_pin_lock';

  @override
  Future<Either<Failure, SettingsState>> getSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load local first
      var themeIndex = prefs.getInt(_themeKey) ?? ThemeMode.system.index;
      var currency = prefs.getString(_currencyKey) ?? 'KES';
      var language = prefs.getString(_languageKey) ?? 'en';
      var pushNotifications = prefs.getBool(_pushNotificationsKey) ?? true;
      var emailSummaries = prefs.getBool(_emailSummariesKey) ?? false;
      var biometricLock = prefs.getBool(_biometricLockKey) ?? false;
      var pinLock = prefs.getBool(_pinLockKey) ?? false;

      // Try sync from backend
      try {
        final res = await ApiClient.instance.get(ApiEndpoints.settings);
        final List<dynamic> remoteSettings = res.data ?? [];
        for (var setting in remoteSettings) {
          final key = setting['key'];
          final value = setting['value'];

          if (key == _themeKey && value != null) {
            themeIndex = ThemeMode.values.indexWhere((m) => m.name == value);
            if (themeIndex == -1) themeIndex = ThemeMode.system.index;
            await prefs.setInt(_themeKey, themeIndex);
          } else if (key == _currencyKey && value != null) {
            currency = value;
            await prefs.setString(_currencyKey, currency);
          } else if (key == _languageKey && value != null) {
            language = value;
            await prefs.setString(_languageKey, language);
          } else if (key == _pushNotificationsKey && value != null) {
            pushNotifications = value == 'true';
            await prefs.setBool(_pushNotificationsKey, pushNotifications);
          } else if (key == _emailSummariesKey && value != null) {
            emailSummaries = value == 'true';
            await prefs.setBool(_emailSummariesKey, emailSummaries);
          } else if (key == _biometricLockKey && value != null) {
            biometricLock = value == 'true';
            await prefs.setBool(_biometricLockKey, biometricLock);
          } else if (key == _pinLockKey && value != null) {
            pinLock = value == 'true';
            await prefs.setBool(_pinLockKey, pinLock);
          }
        }
      } catch (e) {
        // Fallback silently to local cache if offline/error
      }

      final themeMode = ThemeMode.values[themeIndex];

      return Right(SettingsState(
        themeMode: themeMode,
        currency: currency,
        language: language,
        pushNotificationsEnabled: pushNotifications,
        emailSummariesEnabled: emailSummaries,
        biometricLockEnabled: biometricLock,
        pinLockEnabled: pinLock,
      ));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  Future<void> _syncSettingWithBackend(String key, String value) async {
    try {
      await ApiClient.instance
          .put('${ApiEndpoints.settings}/$key', data: {'value': value})
          .timeout(const Duration(seconds: 10));
    } catch (_) {
      // Ignore failures — local cache is source of truth for settings
    }
  }

  @override
  Future<Either<Failure, void>> setThemeMode(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, mode.index);
      await _syncSettingWithBackend(_themeKey, mode.name);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setCurrency(String currency) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currencyKey, currency);
      await _syncSettingWithBackend(_currencyKey, currency);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setLanguage(String language) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, language);
      await _syncSettingWithBackend(_languageKey, language);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setPushNotifications(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_pushNotificationsKey, enabled);
      await _syncSettingWithBackend(_pushNotificationsKey, enabled.toString());
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setEmailSummaries(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_emailSummariesKey, enabled);
      await _syncSettingWithBackend(_emailSummariesKey, enabled.toString());
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setBiometricLock(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_biometricLockKey, enabled);
      await _syncSettingWithBackend(_biometricLockKey, enabled.toString());
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setPinLock(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_pinLockKey, enabled);
      await _syncSettingWithBackend(_pinLockKey, enabled.toString());
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}



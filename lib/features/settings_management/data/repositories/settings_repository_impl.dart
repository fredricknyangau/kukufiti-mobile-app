import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/settings_state.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  static const String _themeKey = 'settings_theme_mode';
  static const String _currencyKey = 'settings_currency';
  static const String _languageKey = 'settings_language';
  static const String _pushNotificationsKey = 'settings_push_notifications';
  static const String _emailSummariesKey = 'settings_email_summaries';

  @override
  Future<Either<Failure, SettingsState>> getSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final themeIndex = prefs.getInt(_themeKey) ?? ThemeMode.system.index;
      final themeMode = ThemeMode.values[themeIndex];
      
      final currency = prefs.getString(_currencyKey) ?? 'KES';
      final language = prefs.getString(_languageKey) ?? 'en';

      final pushNotifications = prefs.getBool(_pushNotificationsKey) ?? true;
      final emailSummaries = prefs.getBool(_emailSummariesKey) ?? false;

      return Right(SettingsState(
        themeMode: themeMode,
        currency: currency,
        language: language,
        pushNotificationsEnabled: pushNotifications,
        emailSummariesEnabled: emailSummaries,
      ));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setThemeMode(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, mode.index);
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
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}


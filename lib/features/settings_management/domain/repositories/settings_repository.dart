import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/settings_state.dart';

abstract class SettingsRepository {
  Future<Either<Failure, SettingsState>> getSettings();
  Future<Either<Failure, void>> setThemeMode(ThemeMode mode);
  Future<Either<Failure, void>> setCurrency(String currency);
  Future<Either<Failure, void>> setLanguage(String language);
  Future<Either<Failure, void>> setPushNotifications(bool enabled);
  Future<Either<Failure, void>> setEmailSummaries(bool enabled);
}


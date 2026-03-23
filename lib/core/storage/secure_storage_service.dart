import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

/// A small wrapper around `flutter_secure_storage` to keep token and credentials storage centralized.
class SecureStorageService {
  static const _authTokenKey = 'auth_token';
  static const _rememberedEmailKey = 'remembered_email';
  static const _hasSeenIntroKey = 'has_seen_intro';

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  /// Auth Token Operations
  static Future<String?> getAuthToken() async {
    try {
      return await _storage.read(key: _authTokenKey);
    } catch (e) {
      debugPrint('SecureStorageService: Failed to read auth token: $e');
      return null;
    }
  }

  static Future<bool> setAuthToken(String token) async {
    try {
      await _storage.write(key: _authTokenKey, value: token);
      return true;
    } catch (e) {
      debugPrint('SecureStorageService: Failed to store auth token: $e');
      return false;
    }
  }

  static Future<bool> deleteAuthToken() async {
    try {
      await _storage.delete(key: _authTokenKey);
      return true;
    } catch (e) {
      debugPrint('SecureStorageService: Failed to delete auth token: $e');
      return false;
    }
  }

  /// Remembered Email Operations
  static Future<String?> getRememberedEmail() async {
    try {
      return await _storage.read(key: _rememberedEmailKey);
    } catch (e) {
      return null;
    }
  }

  static Future<void> saveRememberedEmail(String email) async {
    try {
      await _storage.write(key: _rememberedEmailKey, value: email);
    } catch (_) {}
  }

  static Future<void> clearRememberedEmail() async {
    try {
      await _storage.delete(key: _rememberedEmailKey);
    } catch (_) {}
  }

  /// Intro Seen Operations
  static Future<bool> getHasSeenIntro() async {
    try {
      final value = await _storage.read(key: _hasSeenIntroKey);
      return value == 'true';
    } catch (e) {
      return false;
    }
  }

  static Future<void> setHasSeenIntro(bool value) async {
    try {
      await _storage.write(key: _hasSeenIntroKey, value: value.toString());
    } catch (_) {}
  }
}

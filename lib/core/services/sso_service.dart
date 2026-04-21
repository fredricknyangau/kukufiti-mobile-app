import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/utils/error_handler.dart';

/// Result returned from a successful SSO sign-in.
class SsoResult {
  final String accessToken;
  final bool isNewUser;

  const SsoResult({required this.accessToken, required this.isNewUser});
}

/// Handles Google and Apple SSO flows.
///
/// Each method:
/// 1. Opens the platform-native sign-in sheet.
/// 2. Sends the resulting credential to the KukuFiti backend.
/// 3. Returns a [SsoResult] containing the JWT and whether the account is new.
///
/// Throws a [String] error message on failure (already user-friendly).
class SsoService {
  static final _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  // ─── Google ───────────────────────────────────────────────────────────────

  static Future<SsoResult> signInWithGoogle() async {
    // 1. Launch the Google account picker
    GoogleSignInAccount? account;
    try {
      account = await _googleSignIn.signIn();
    } catch (e) {
      throw 'Google sign-in was cancelled or failed. Please try again.';
    }

    if (account == null) {
      throw 'Google sign-in was cancelled.';
    }

    // 2. Get the authentication tokens
    final auth = await account.authentication;
    final idToken = auth.idToken;

    if (idToken == null) {
      throw 'Could not retrieve Google ID token. Try again.';
    }

    // 3. Verify with our backend and get a KukuFiti JWT
    try {
      final response = await ApiClient.instance.post(
        '/auth/google',
        data: {'id_token': idToken},
      );

      return SsoResult(
        accessToken: response.data['access_token'] as String,
        isNewUser: (response.data['is_new_user'] as bool?) ?? false,
      );
    } on DioException catch (e) {
      throw getFriendlyErrorMessage(e);
    } catch (e) {
      throw 'Google sign-in failed. Please try again.';
    }
  }

  // ─── Apple ────────────────────────────────────────────────────────────────

  /// Apple Sign-In is only available on iOS 13+ and macOS 10.15+.
  static bool get isAppleSignInAvailable =>
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  static Future<SsoResult> signInWithApple() async {
    if (!isAppleSignInAvailable) {
      throw 'Sign in with Apple is only available on iOS and macOS.';
    }

    // 1. Request Apple credential
    final AuthorizationCredentialAppleID credential;
    try {
      credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw 'Apple sign-in was cancelled.';
      }
      throw 'Apple sign-in failed: ${e.message}';
    }

    final identityToken = credential.identityToken;
    if (identityToken == null) {
      throw 'Could not retrieve Apple identity token. Try again.';
    }

    // Combine given + family name (Apple only sends name on first sign-in)
    final fullName = [
      credential.givenName,
      credential.familyName,
    ].where((n) => n != null && n.isNotEmpty).join(' ');

    // 2. Verify with our backend
    try {
      final response = await ApiClient.instance.post(
        '/auth/apple',
        data: {
          'identity_token': identityToken,
          if (fullName.isNotEmpty) 'full_name': fullName,
        },
      );

      return SsoResult(
        accessToken: response.data['access_token'] as String,
        isNewUser: (response.data['is_new_user'] as bool?) ?? false,
      );
    } on DioException catch (e) {
      throw getFriendlyErrorMessage(e);
    } catch (e) {
      throw 'Apple sign-in failed. Please try again.';
    }
  }
}

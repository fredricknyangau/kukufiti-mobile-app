import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../core/storage/secure_storage_service.dart';

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = true,
    this.error,
  });

  AuthState copyWith({bool? isAuthenticated, bool? isLoading, String? error}) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    _checkAuthStatus();
    return const AuthState();
  }

  Future<void> _checkAuthStatus() async {
    final token = await SecureStorageService.getAuthToken();

    if (token != null && token.isNotEmpty) {
      state = state.copyWith(isAuthenticated: true, isLoading: false);
    } else {
      state = state.copyWith(isAuthenticated: false, isLoading: false);
    }
  }

  /// Manually set authentication state (used for biometric login)
  void loginWithToken(String token) {
    state = state.copyWith(isAuthenticated: true, isLoading: false, error: null);
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await ApiClient.instance.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );

      final token = response.data['access_token'];
      if (token != null) {
        await SecureStorageService.setAuthToken(token);
        state = state.copyWith(isAuthenticated: true, isLoading: false);
      } else {
        throw Exception("Invalid token received");
      }
    } catch (e) {
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await SecureStorageService.deleteAuthToken();
    state = const AuthState(isAuthenticated: false, isLoading: false);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

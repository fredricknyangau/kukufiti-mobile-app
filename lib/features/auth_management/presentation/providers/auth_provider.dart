import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mobile/core/storage/secure_storage_service.dart';
import 'package:mobile/features/auth_management/domain/repositories/auth_repository.dart';
import 'package:mobile/features/auth_management/data/repositories/auth_repository_impl.dart';

part 'auth_provider.g.dart';

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl();
}

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final bool hasSeenIntro;
  final String? error;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = true,
    this.hasSeenIntro = false,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    bool? hasSeenIntro,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      hasSeenIntro: hasSeenIntro ?? this.hasSeenIntro,
      error: error,
    );
  }
}

@riverpod
class Auth extends _$Auth {
  @override
  AuthState build() {
    _checkAuthStatus();
    return const AuthState();
  }

  Future<void> _checkAuthStatus() async {
    final token = await SecureStorageService.getAuthToken();
    final hasSeenIntro = await SecureStorageService.getHasSeenIntro();

    state = state.copyWith(
      isAuthenticated: token != null && token.isNotEmpty,
      hasSeenIntro: hasSeenIntro,
      isLoading: false,
    );
  }

  Future<void> setHasSeenIntro(bool value) async {
    await SecureStorageService.setHasSeenIntro(value);
    state = state.copyWith(hasSeenIntro: value);
  }

  Future<void> loginWithToken(String token) async {
    await SecureStorageService.setAuthToken(token);
    state = state.copyWith(isAuthenticated: true, isLoading: false, error: null);
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.login(email, password);

    result.fold(
      (failure) {
        state = state.copyWith(
          isAuthenticated: false,
          isLoading: false,
          error: failure.message,
        );
      },
      (token) async {
        await SecureStorageService.setAuthToken(token);
        state = state.copyWith(isAuthenticated: true, isLoading: false);
      },
    );
  }

  Future<String?> sendOtp(String phoneNumber) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.sendOtp(phoneNumber);

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return null;
      },
      (otpCode) {
        state = state.copyWith(isLoading: false);
        return otpCode;
      },
    );
  }

  Future<bool?> verifyOtp(String phoneNumber, String code) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.verifyOtp(phoneNumber, code);

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return null;
      },
      (data) async {
        final token = data.$1;
        final isNewUser = data.$2;
        await SecureStorageService.setAuthToken(token);
        state = state.copyWith(isAuthenticated: true, isLoading: false);
        return isNewUser;
      },
    );
  }

  Future<bool?> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.signInWithGoogle();

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return null;
      },
      (data) async {
        final token = data.$1;
        final isNewUser = data.$2;
        await SecureStorageService.setAuthToken(token);
        state = state.copyWith(isAuthenticated: true, isLoading: false);
        return isNewUser;
      },
    );
  }

  Future<bool?> signInWithApple() async {
    state = state.copyWith(isLoading: true, error: null);
    
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.signInWithApple();

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return null;
      },
      (data) async {
        final token = data.$1;
        final isNewUser = data.$2;
        await SecureStorageService.setAuthToken(token);
        state = state.copyWith(isAuthenticated: true, isLoading: false);
        return isNewUser;
      },
    );
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await SecureStorageService.deleteAuthToken();
    state = const AuthState(isAuthenticated: false, isLoading: false);
  }
}

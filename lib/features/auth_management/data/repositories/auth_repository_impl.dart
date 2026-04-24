import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/api_endpoints.dart';
import 'package:mobile/features/auth_management/domain/repositories/auth_repository.dart';
import 'package:mobile/core/utils/error_handler.dart';
import 'package:mobile/core/services/sso_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<Either<Failure, String>> sendOtp(String phoneNumber) async {
    try {
      final response = await ApiClient.instance.post(
        ApiEndpoints.sendOtp,
        data: {'phone_number': phoneNumber},
      );
      // Backend returns 'debug_code' in dev mode, check both
      final otpCode = (response.data['debug_code'] ?? response.data['code'])?.toString() ?? 'unknown';
      return Right(otpCode);
    } catch (e) {
      return Left(ServerFailure(getFriendlyErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, (String, bool)>> verifyOtp(String phoneNumber, String code) async {
    try {
      final response = await ApiClient.instance.post(
        ApiEndpoints.verifyOtp,
        data: {'phone_number': phoneNumber, 'code': code},
      );
      final token = response.data['access_token']?.toString();
      final isNewUser = response.data['is_new_user'] ?? false;
      if (token != null) {
        return Right((token, isNewUser as bool));
      }
      return Left(ServerFailure('Invalid response: Missing token'));
    } catch (e) {
      return Left(ServerFailure(getFriendlyErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, String>> login(String email, String password) async {
    try {
      final response = await ApiClient.instance.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );
      final token = response.data['access_token']?.toString();
      if (token != null) {
        return Right(token);
      }
      return Left(ServerFailure('Invalid response: Missing token'));
    } catch (e) {
      return Left(ServerFailure(getFriendlyErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, (String, bool)>> signInWithGoogle() async {
    try {
      final result = await SsoService.signInWithGoogle();
      return Right((result.accessToken, result.isNewUser));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, (String, bool)>> signInWithApple() async {
    try {
      final result = await SsoService.signInWithApple();
      return Right((result.accessToken, result.isNewUser));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

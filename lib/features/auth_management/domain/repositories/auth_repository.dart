import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, String>> sendOtp(String phoneNumber);
  Future<Either<Failure, (String, bool)>> verifyOtp(String phoneNumber, String code);
  Future<Either<Failure, String>> login(String email, String password);
}

import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/api_endpoints.dart';
import 'package:mobile/core/utils/error_handler.dart';
import 'package:mobile/features/billing_management/domain/repositories/billing_repository.dart';

class BillingRepositoryImpl implements BillingRepository {
  @override
  Future<Either<Failure, List<dynamic>>> fetchPlans() async {
    try {
      final response = await ApiClient.instance.get(ApiEndpoints.plans);
      return Right(response.data as List<dynamic>);
    } catch (e) {
      return Left(ServerFailure(getFriendlyErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, void>> submitSubscription(String planType, String billingPeriod, String phone) async {
    try {
      final payload = {
        'plan_type': planType,
        'billing_period': billingPeriod,
        'phone_number': phone,
      };
      await ApiClient.instance.post(ApiEndpoints.subscribe, data: payload);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(getFriendlyErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> fetchPlanDetails() async {
    try {
      final response = await ApiClient.instance.get(ApiEndpoints.planDetails);
      final data = response.data is Map ? response.data : (response.data as Map<String, dynamic>)['data'];
      return Right(Map<String, dynamic>.from(data));
    } catch (e) {
      return Left(ServerFailure(getFriendlyErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getMySubscription() async {
    try {
      final response = await ApiClient.instance.get(ApiEndpoints.mySubscription);
      final data = response.data is Map ? response.data : (response.data as Map<String, dynamic>)['data'];
      return Right(Map<String, dynamic>.from(data ?? {}));
    } catch (e) {
      return Left(ServerFailure(getFriendlyErrorMessage(e)));
    }
  }
}

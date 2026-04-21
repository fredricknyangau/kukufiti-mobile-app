import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failures.dart';

abstract class BillingRepository {
  Future<Either<Failure, List<dynamic>>> fetchPlans();
  Future<Either<Failure, void>> submitSubscription(String planType, String billingPeriod, String phone);
  Future<Either<Failure, Map<String, dynamic>>> fetchPlanDetails();
  Future<Either<Failure, Map<String, dynamic>>> getMySubscription();
}

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobile/features/billing_management/domain/repositories/billing_repository.dart';
import 'package:mobile/features/billing_management/data/repositories/billing_repository_impl.dart';
import 'package:mobile/core/storage/secure_storage_service.dart';

part 'billing_providers.g.dart';

@riverpod
BillingRepository billingRepository(Ref ref) {
  return BillingRepositoryImpl();
}

class BillingState {
  final List<dynamic> plans;
  final bool isLoading;
  final String? error;

  const BillingState({
    this.plans = const [],
    this.isLoading = true,
    this.error,
  });

  BillingState copyWith({
    List<dynamic>? plans,
    bool? isLoading,
    String? error,
  }) {
    return BillingState(
      plans: plans ?? this.plans,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

@riverpod
class Billing extends _$Billing {
  @override
  BillingState build() {
    return const BillingState();
  }

  Future<void> fetchPlans() async {
    state = state.copyWith(isLoading: true, error: null);
    final repo = ref.read(billingRepositoryProvider);
    final result = await repo.fetchPlans();
    
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (plans) => state = state.copyWith(isLoading: false, plans: plans),
    );
  }

  Future<bool> submitSubscription(String planType, String billingPeriod, String phone) async {
    final repo = ref.read(billingRepositoryProvider);
    final result = await repo.submitSubscription(planType, billingPeriod, phone);
    
    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
      (_) => true,
    );
  }
}

@riverpod
Future<Map<String, dynamic>> planDetails(Ref ref) async {
  final repo = ref.watch(billingRepositoryProvider);
  final result = await repo.fetchPlanDetails();
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (data) => data,
  );
}

// Alias for subscriptionProvider as it's used throughout the app
@riverpod
Future<Map<String, dynamic>> subscription(Ref ref) {
  return ref.watch(planDetailsProvider.future);
}

@riverpod
Future<Map<String, dynamic>> mySubscription(Ref ref) async {
  final token = await SecureStorageService.getAuthToken();
  if (token == null || token.isEmpty) {
    return {
      'plan_type': 'STARTER',
      'status': 'ACTIVE',
    };
  }

  final repo = ref.watch(billingRepositoryProvider);
  final result = await repo.getMySubscription();
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (data) => data,
  );
}

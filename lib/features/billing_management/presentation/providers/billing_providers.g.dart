// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'billing_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(billingRepository)
final billingRepositoryProvider = BillingRepositoryProvider._();

final class BillingRepositoryProvider
    extends
        $FunctionalProvider<
          BillingRepository,
          BillingRepository,
          BillingRepository
        >
    with $Provider<BillingRepository> {
  BillingRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'billingRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$billingRepositoryHash();

  @$internal
  @override
  $ProviderElement<BillingRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BillingRepository create(Ref ref) {
    return billingRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BillingRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BillingRepository>(value),
    );
  }
}

String _$billingRepositoryHash() => r'0f0874d16624bbb5a121565ebbf952699d8b9d2c';

@ProviderFor(Billing)
final billingProvider = BillingProvider._();

final class BillingProvider extends $NotifierProvider<Billing, BillingState> {
  BillingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'billingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$billingHash();

  @$internal
  @override
  Billing create() => Billing();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BillingState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BillingState>(value),
    );
  }
}

String _$billingHash() => r'0afed53c299739e047602063ef946e2b45ef9a8c';

abstract class _$Billing extends $Notifier<BillingState> {
  BillingState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<BillingState, BillingState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BillingState, BillingState>,
              BillingState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(planDetails)
final planDetailsProvider = PlanDetailsProvider._();

final class PlanDetailsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, dynamic>>,
          Map<String, dynamic>,
          FutureOr<Map<String, dynamic>>
        >
    with
        $FutureModifier<Map<String, dynamic>>,
        $FutureProvider<Map<String, dynamic>> {
  PlanDetailsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'planDetailsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$planDetailsHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, dynamic>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, dynamic>> create(Ref ref) {
    return planDetails(ref);
  }
}

String _$planDetailsHash() => r'6170278bfd27d183d85ed04251aa75ab50dbbb28';

@ProviderFor(subscription)
final subscriptionProvider = SubscriptionProvider._();

final class SubscriptionProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, dynamic>>,
          Map<String, dynamic>,
          FutureOr<Map<String, dynamic>>
        >
    with
        $FutureModifier<Map<String, dynamic>>,
        $FutureProvider<Map<String, dynamic>> {
  SubscriptionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'subscriptionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$subscriptionHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, dynamic>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, dynamic>> create(Ref ref) {
    return subscription(ref);
  }
}

String _$subscriptionHash() => r'9d116278d1719cfd3b6da8c3ced3e8e8212021bf';

@ProviderFor(mySubscription)
final mySubscriptionProvider = MySubscriptionProvider._();

final class MySubscriptionProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, dynamic>>,
          Map<String, dynamic>,
          FutureOr<Map<String, dynamic>>
        >
    with
        $FutureModifier<Map<String, dynamic>>,
        $FutureProvider<Map<String, dynamic>> {
  MySubscriptionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mySubscriptionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mySubscriptionHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, dynamic>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, dynamic>> create(Ref ref) {
    return mySubscription(ref);
  }
}

String _$mySubscriptionHash() => r'69b5ac58b7353fa79a4fd94c156d224a47139cdd';

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'availability_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Availability repository, or null in guest mode: an athlete with no account
/// has no coach to declare a week to.

@ProviderFor(availabilityRepository)
const availabilityRepositoryProvider = AvailabilityRepositoryProvider._();

/// Availability repository, or null in guest mode: an athlete with no account
/// has no coach to declare a week to.

final class AvailabilityRepositoryProvider
    extends
        $FunctionalProvider<
          AvailabilityRepository?,
          AvailabilityRepository?,
          AvailabilityRepository?
        >
    with $Provider<AvailabilityRepository?> {
  /// Availability repository, or null in guest mode: an athlete with no account
  /// has no coach to declare a week to.
  const AvailabilityRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'availabilityRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$availabilityRepositoryHash();

  @$internal
  @override
  $ProviderElement<AvailabilityRepository?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AvailabilityRepository? create(Ref ref) {
    return availabilityRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AvailabilityRepository? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AvailabilityRepository?>(value),
    );
  }
}

String _$availabilityRepositoryHash() =>
    r'472056971a777f263cea03d180e93bda0a5321bf';

/// Every calendar week the athlete has declared. Empty when they are not
/// signed in.

@ProviderFor(MyAvailability)
const myAvailabilityProvider = MyAvailabilityProvider._();

/// Every calendar week the athlete has declared. Empty when they are not
/// signed in.
final class MyAvailabilityProvider
    extends $AsyncNotifierProvider<MyAvailability, List<WeekAvailability>> {
  /// Every calendar week the athlete has declared. Empty when they are not
  /// signed in.
  const MyAvailabilityProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myAvailabilityProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myAvailabilityHash();

  @$internal
  @override
  MyAvailability create() => MyAvailability();
}

String _$myAvailabilityHash() => r'c494c5257632b82021f2a8e62919b1a247bb16f4';

/// Every calendar week the athlete has declared. Empty when they are not
/// signed in.

abstract class _$MyAvailability extends $AsyncNotifier<List<WeekAvailability>> {
  FutureOr<List<WeekAvailability>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<AsyncValue<List<WeekAvailability>>, List<WeekAvailability>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<WeekAvailability>>,
                List<WeekAvailability>
              >,
              AsyncValue<List<WeekAvailability>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// The reminder the coach set, with the weeks already declared, mirrored to the
/// device so the nudge survives an offline launch. Null once when the athlete
/// is signed out, which is what stops a stale plan reaching the next account.

@ProviderFor(availabilityPlanCache)
const availabilityPlanCacheProvider = AvailabilityPlanCacheProvider._();

/// The reminder the coach set, with the weeks already declared, mirrored to the
/// device so the nudge survives an offline launch. Null once when the athlete
/// is signed out, which is what stops a stale plan reaching the next account.

final class AvailabilityPlanCacheProvider
    extends
        $FunctionalProvider<
          AsyncValue<CachedAvailabilityPlan?>,
          CachedAvailabilityPlan?,
          FutureOr<CachedAvailabilityPlan?>
        >
    with
        $FutureModifier<CachedAvailabilityPlan?>,
        $FutureProvider<CachedAvailabilityPlan?> {
  /// The reminder the coach set, with the weeks already declared, mirrored to the
  /// device so the nudge survives an offline launch. Null once when the athlete
  /// is signed out, which is what stops a stale plan reaching the next account.
  const AvailabilityPlanCacheProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'availabilityPlanCacheProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$availabilityPlanCacheHash();

  @$internal
  @override
  $FutureProviderElement<CachedAvailabilityPlan?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CachedAvailabilityPlan?> create(Ref ref) {
    return availabilityPlanCache(ref);
  }
}

String _$availabilityPlanCacheHash() =>
    r'232ab9c08b6623653bafc53d8a0764847fdac9f3';

/// Rewrites the pending availability reminders whenever the coach setting or
/// the declared weeks change. Watched by the app shell so it stays alive.

@ProviderFor(availabilityReminderSync)
const availabilityReminderSyncProvider = AvailabilityReminderSyncProvider._();

/// Rewrites the pending availability reminders whenever the coach setting or
/// the declared weeks change. Watched by the app shell so it stays alive.

final class AvailabilityReminderSyncProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// Rewrites the pending availability reminders whenever the coach setting or
  /// the declared weeks change. Watched by the app shell so it stays alive.
  const AvailabilityReminderSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'availabilityReminderSyncProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$availabilityReminderSyncHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return availabilityReminderSync(ref);
  }
}

String _$availabilityReminderSyncHash() =>
    r'1eaa24ba3fe5ee717dd2f0e1248929ea5cb62aa6';

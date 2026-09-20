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

/// The calendar weeks the athlete can edit, with what they planned in them:
/// this week and the next two, which is what the week switcher offers. Empty
/// when they are not signed in.
///
/// Windowed rather than the whole history, because a week now carries up to
/// 140 activities and the screen renders one week at a time. Which weeks the
/// athlete has ever declared is a different question, answered by
/// [declaredWeekStarts]: do not derive it from this list.

@ProviderFor(MyAvailability)
const myAvailabilityProvider = MyAvailabilityProvider._();

/// The calendar weeks the athlete can edit, with what they planned in them:
/// this week and the next two, which is what the week switcher offers. Empty
/// when they are not signed in.
///
/// Windowed rather than the whole history, because a week now carries up to
/// 140 activities and the screen renders one week at a time. Which weeks the
/// athlete has ever declared is a different question, answered by
/// [declaredWeekStarts]: do not derive it from this list.
final class MyAvailabilityProvider
    extends $AsyncNotifierProvider<MyAvailability, AvailabilityWeeks> {
  /// The calendar weeks the athlete can edit, with what they planned in them:
  /// this week and the next two, which is what the week switcher offers. Empty
  /// when they are not signed in.
  ///
  /// Windowed rather than the whole history, because a week now carries up to
  /// 140 activities and the screen renders one week at a time. Which weeks the
  /// athlete has ever declared is a different question, answered by
  /// [declaredWeekStarts]: do not derive it from this list.
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

String _$myAvailabilityHash() => r'c9687bb679b212bf29b045be943e26b9564cc62a';

/// The calendar weeks the athlete can edit, with what they planned in them:
/// this week and the next two, which is what the week switcher offers. Empty
/// when they are not signed in.
///
/// Windowed rather than the whole history, because a week now carries up to
/// 140 activities and the screen renders one week at a time. Which weeks the
/// athlete has ever declared is a different question, answered by
/// [declaredWeekStarts]: do not derive it from this list.

abstract class _$MyAvailability extends $AsyncNotifier<AvailabilityWeeks> {
  FutureOr<AvailabilityWeeks> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<AvailabilityWeeks>, AvailabilityWeeks>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AvailabilityWeeks>, AvailabilityWeeks>,
              AsyncValue<AvailabilityWeeks>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Every calendar week the athlete has declared, dates alone and never
/// windowed.
///
/// Its own provider off its own endpoint, because the reminder planner drops a
/// nudge for a week that was already answered. Fed from the windowed list
/// instead, it would forget the weeks outside the window and nudge the athlete
/// about weeks they have already sent, which is the regression bounding the
/// list could otherwise introduce silently.

@ProviderFor(declaredWeekStarts)
const declaredWeekStartsProvider = DeclaredWeekStartsProvider._();

/// Every calendar week the athlete has declared, dates alone and never
/// windowed.
///
/// Its own provider off its own endpoint, because the reminder planner drops a
/// nudge for a week that was already answered. Fed from the windowed list
/// instead, it would forget the weeks outside the window and nudge the athlete
/// about weeks they have already sent, which is the regression bounding the
/// list could otherwise introduce silently.

final class DeclaredWeekStartsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Set<DateTime>>,
          Set<DateTime>,
          FutureOr<Set<DateTime>>
        >
    with $FutureModifier<Set<DateTime>>, $FutureProvider<Set<DateTime>> {
  /// Every calendar week the athlete has declared, dates alone and never
  /// windowed.
  ///
  /// Its own provider off its own endpoint, because the reminder planner drops a
  /// nudge for a week that was already answered. Fed from the windowed list
  /// instead, it would forget the weeks outside the window and nudge the athlete
  /// about weeks they have already sent, which is the regression bounding the
  /// list could otherwise introduce silently.
  const DeclaredWeekStartsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'declaredWeekStartsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$declaredWeekStartsHash();

  @$internal
  @override
  $FutureProviderElement<Set<DateTime>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Set<DateTime>> create(Ref ref) {
    return declaredWeekStarts(ref);
  }
}

String _$declaredWeekStartsHash() =>
    r'7ac8868ce1694dc6484596c2e7b77f45d928a55c';

/// The reminder the coach set, with the weeks already declared, mirrored to the
/// device so the nudge survives an offline launch. Dropped once the athlete is
/// resolved to be signed out, which is what stops a stale plan reaching the
/// next account.

@ProviderFor(availabilityPlanCache)
const availabilityPlanCacheProvider = AvailabilityPlanCacheProvider._();

/// The reminder the coach set, with the weeks already declared, mirrored to the
/// device so the nudge survives an offline launch. Dropped once the athlete is
/// resolved to be signed out, which is what stops a stale plan reaching the
/// next account.

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
  /// device so the nudge survives an offline launch. Dropped once the athlete is
  /// resolved to be signed out, which is what stops a stale plan reaching the
  /// next account.
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
    r'1db246719b26e8074a5211fc51dd7a3282b2a5e4';

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

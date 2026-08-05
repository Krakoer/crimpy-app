// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(notificationService)
const notificationServiceProvider = NotificationServiceProvider._();

final class NotificationServiceProvider
    extends
        $FunctionalProvider<
          NotificationService,
          NotificationService,
          NotificationService
        >
    with $Provider<NotificationService> {
  const NotificationServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationServiceHash();

  @$internal
  @override
  $ProviderElement<NotificationService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationService create(Ref ref) {
    return notificationService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationService>(value),
    );
  }
}

String _$notificationServiceHash() =>
    r'585c1e42ea844e71a2b76b80b165adfe2c5c8529';

@ProviderFor(notificationPreferencesService)
const notificationPreferencesServiceProvider =
    NotificationPreferencesServiceProvider._();

final class NotificationPreferencesServiceProvider
    extends
        $FunctionalProvider<
          NotificationPreferencesService,
          NotificationPreferencesService,
          NotificationPreferencesService
        >
    with $Provider<NotificationPreferencesService> {
  const NotificationPreferencesServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationPreferencesServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationPreferencesServiceHash();

  @$internal
  @override
  $ProviderElement<NotificationPreferencesService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationPreferencesService create(Ref ref) {
    return notificationPreferencesService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationPreferencesService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationPreferencesService>(
        value,
      ),
    );
  }
}

String _$notificationPreferencesServiceHash() =>
    r'90216420eab0069bf1ea1241dcd376c248e94742';

@ProviderFor(trainingReminderScheduler)
const trainingReminderSchedulerProvider = TrainingReminderSchedulerProvider._();

final class TrainingReminderSchedulerProvider
    extends
        $FunctionalProvider<
          TrainingReminderScheduler,
          TrainingReminderScheduler,
          TrainingReminderScheduler
        >
    with $Provider<TrainingReminderScheduler> {
  const TrainingReminderSchedulerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trainingReminderSchedulerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trainingReminderSchedulerHash();

  @$internal
  @override
  $ProviderElement<TrainingReminderScheduler> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TrainingReminderScheduler create(Ref ref) {
    return trainingReminderScheduler(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TrainingReminderScheduler value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TrainingReminderScheduler>(value),
    );
  }
}

String _$trainingReminderSchedulerHash() =>
    r'abd0017bd89d4d6ef0c27b1bba6eff308e8482aa';

/// Whether the OS still accepts our notifications. Revoking the permission in
/// the system settings leaves [NotificationPreferences.enabled] untouched, so
/// the screen has to ask rather than trust it. Auto disposed to re-ask on every
/// visit.

@ProviderFor(reminderPermission)
const reminderPermissionProvider = ReminderPermissionProvider._();

/// Whether the OS still accepts our notifications. Revoking the permission in
/// the system settings leaves [NotificationPreferences.enabled] untouched, so
/// the screen has to ask rather than trust it. Auto disposed to re-ask on every
/// visit.

final class ReminderPermissionProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Whether the OS still accepts our notifications. Revoking the permission in
  /// the system settings leaves [NotificationPreferences.enabled] untouched, so
  /// the screen has to ask rather than trust it. Auto disposed to re-ask on every
  /// visit.
  const ReminderPermissionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reminderPermissionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reminderPermissionHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return reminderPermission(ref);
  }
}

String _$reminderPermissionHash() =>
    r'72c02ed8e045705331b60ac8e43eee8bb5256c7a';

/// The training reminder settings, and the actions that change them.

@ProviderFor(NotificationPreferencesController)
const notificationPreferencesControllerProvider =
    NotificationPreferencesControllerProvider._();

/// The training reminder settings, and the actions that change them.
final class NotificationPreferencesControllerProvider
    extends
        $AsyncNotifierProvider<
          NotificationPreferencesController,
          NotificationPreferences
        > {
  /// The training reminder settings, and the actions that change them.
  const NotificationPreferencesControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationPreferencesControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$notificationPreferencesControllerHash();

  @$internal
  @override
  NotificationPreferencesController create() =>
      NotificationPreferencesController();
}

String _$notificationPreferencesControllerHash() =>
    r'1d40e3d69b2f184468c15669e1fc19ca10e6126b';

/// The training reminder settings, and the actions that change them.

abstract class _$NotificationPreferencesController
    extends $AsyncNotifier<NotificationPreferences> {
  FutureOr<NotificationPreferences> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              AsyncValue<NotificationPreferences>,
              NotificationPreferences
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<NotificationPreferences>,
                NotificationPreferences
              >,
              AsyncValue<NotificationPreferences>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// The program schedule reminders are planned from: freshly fetched when the
/// user is online, otherwise the last copy stored on the device.

@ProviderFor(programScheduleCache)
const programScheduleCacheProvider = ProgramScheduleCacheProvider._();

/// The program schedule reminders are planned from: freshly fetched when the
/// user is online, otherwise the last copy stored on the device.

final class ProgramScheduleCacheProvider
    extends
        $FunctionalProvider<
          AsyncValue<CachedProgramSchedule?>,
          CachedProgramSchedule?,
          FutureOr<CachedProgramSchedule?>
        >
    with
        $FutureModifier<CachedProgramSchedule?>,
        $FutureProvider<CachedProgramSchedule?> {
  /// The program schedule reminders are planned from: freshly fetched when the
  /// user is online, otherwise the last copy stored on the device.
  const ProgramScheduleCacheProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'programScheduleCacheProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$programScheduleCacheHash();

  @$internal
  @override
  $FutureProviderElement<CachedProgramSchedule?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CachedProgramSchedule?> create(Ref ref) {
    return programScheduleCache(ref);
  }
}

String _$programScheduleCacheHash() =>
    r'29832590dca5a7027f237a51f578960dca44d269';

/// Rewrites the pending reminders whenever the settings, the program schedule
/// or the logged sessions change. Watched by the app shell so it stays alive.

@ProviderFor(trainingReminderSync)
const trainingReminderSyncProvider = TrainingReminderSyncProvider._();

/// Rewrites the pending reminders whenever the settings, the program schedule
/// or the logged sessions change. Watched by the app shell so it stays alive.

final class TrainingReminderSyncProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// Rewrites the pending reminders whenever the settings, the program schedule
  /// or the logged sessions change. Watched by the app shell so it stays alive.
  const TrainingReminderSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trainingReminderSyncProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trainingReminderSyncHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return trainingReminderSync(ref);
  }
}

String _$trainingReminderSyncHash() =>
    r'32bce71c0d0bd94df566c00efbc2b3c7707dac0a';

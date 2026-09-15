// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coach_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Enrollment repository, or null in guest mode: an athlete with no account
/// has no coach to be enrolled with.

@ProviderFor(coachEnrollmentRepository)
const coachEnrollmentRepositoryProvider = CoachEnrollmentRepositoryProvider._();

/// Enrollment repository, or null in guest mode: an athlete with no account
/// has no coach to be enrolled with.

final class CoachEnrollmentRepositoryProvider
    extends
        $FunctionalProvider<
          CoachEnrollmentRepository?,
          CoachEnrollmentRepository?,
          CoachEnrollmentRepository?
        >
    with $Provider<CoachEnrollmentRepository?> {
  /// Enrollment repository, or null in guest mode: an athlete with no account
  /// has no coach to be enrolled with.
  const CoachEnrollmentRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'coachEnrollmentRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$coachEnrollmentRepositoryHash();

  @$internal
  @override
  $ProviderElement<CoachEnrollmentRepository?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CoachEnrollmentRepository? create(Ref ref) {
    return coachEnrollmentRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CoachEnrollmentRepository? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CoachEnrollmentRepository?>(value),
    );
  }
}

String _$coachEnrollmentRepositoryHash() =>
    r'6f55b52f2dced91aad949c645dfdf46d09277d1d';

/// The coach this athlete is enrolled with, null when they have none.
///
/// A failed fetch also answers null rather than throwing: every caller so far
/// only decides whether to offer something coach related, and an offline
/// launch should drop the offer, not fail around it.

@ProviderFor(coachEnrollment)
const coachEnrollmentProvider = CoachEnrollmentProvider._();

/// The coach this athlete is enrolled with, null when they have none.
///
/// A failed fetch also answers null rather than throwing: every caller so far
/// only decides whether to offer something coach related, and an offline
/// launch should drop the offer, not fail around it.

final class CoachEnrollmentProvider
    extends
        $FunctionalProvider<
          AsyncValue<CoachEnrollment?>,
          CoachEnrollment?,
          FutureOr<CoachEnrollment?>
        >
    with $FutureModifier<CoachEnrollment?>, $FutureProvider<CoachEnrollment?> {
  /// The coach this athlete is enrolled with, null when they have none.
  ///
  /// A failed fetch also answers null rather than throwing: every caller so far
  /// only decides whether to offer something coach related, and an offline
  /// launch should drop the offer, not fail around it.
  const CoachEnrollmentProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'coachEnrollmentProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$coachEnrollmentHash();

  @$internal
  @override
  $FutureProviderElement<CoachEnrollment?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CoachEnrollment?> create(Ref ref) {
    return coachEnrollment(ref);
  }
}

String _$coachEnrollmentHash() => r'09c8a2728821fc75fea8f772dbd8adc35c3270ff';

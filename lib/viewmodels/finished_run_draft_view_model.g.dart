// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'finished_run_draft_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Where a finished run waits for its review to be saved. Krakoer/crimpy#146.

@ProviderFor(finishedRunDraftRepository)
const finishedRunDraftRepositoryProvider =
    FinishedRunDraftRepositoryProvider._();

/// Where a finished run waits for its review to be saved. Krakoer/crimpy#146.

final class FinishedRunDraftRepositoryProvider
    extends
        $FunctionalProvider<
          FinishedRunDraftRepository,
          FinishedRunDraftRepository,
          FinishedRunDraftRepository
        >
    with $Provider<FinishedRunDraftRepository> {
  /// Where a finished run waits for its review to be saved. Krakoer/crimpy#146.
  const FinishedRunDraftRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'finishedRunDraftRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$finishedRunDraftRepositoryHash();

  @$internal
  @override
  $ProviderElement<FinishedRunDraftRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FinishedRunDraftRepository create(Ref ref) {
    return finishedRunDraftRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FinishedRunDraftRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FinishedRunDraftRepository>(value),
    );
  }
}

String _$finishedRunDraftRepositoryHash() =>
    r'028cbe65d222ca3a6e7625c4cd56c0311431973d';

/// Who a run finished now belongs to: the signed in user, or the guest.
///
/// Read once the auth state has settled, never from the cold start's loading
/// state, which would name the guest for an athlete who is signed in.

@ProviderFor(runDraftOwner)
const runDraftOwnerProvider = RunDraftOwnerProvider._();

/// Who a run finished now belongs to: the signed in user, or the guest.
///
/// Read once the auth state has settled, never from the cold start's loading
/// state, which would name the guest for an athlete who is signed in.

final class RunDraftOwnerProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// Who a run finished now belongs to: the signed in user, or the guest.
  ///
  /// Read once the auth state has settled, never from the cold start's loading
  /// state, which would name the guest for an athlete who is signed in.
  const RunDraftOwnerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'runDraftOwnerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$runDraftOwnerHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return runDraftOwner(ref);
  }
}

String _$runDraftOwnerHash() => r'99c3955dc51869c82e6216d6c67bdb73225bac17';

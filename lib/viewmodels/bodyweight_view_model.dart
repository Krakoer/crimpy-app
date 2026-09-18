import 'dart:async';

import 'package:crimpy/repositories/bodyweight_repository.dart';
import 'package:crimpy/services/bodyweight_service.dart';
import 'package:crimpy/viewmodels/auth_view_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bodyweight_view_model.g.dart';

@Riverpod(keepAlive: true)
BodyweightService bodyweightService(Ref ref) => BodyweightService();

@Riverpod(keepAlive: true)
BodyweightRepository bodyweightRepository(Ref ref) => BodyweightRepository(
  ref.watch(apiClientProvider),
  service: ref.watch(bodyweightServiceProvider),
);

/// Whether the latest measurement is still waiting to reach the server, so the
/// athlete can be told their coach is not seeing it yet.
@riverpod
Future<bool> bodyweightPending(Ref ref) =>
    ref.watch(bodyweightRepositoryProvider).hasPending();

/// The athlete bodyweight in kilograms, null until it is entered or measured.
///
/// The value is cached on the device because a run must not need the network,
/// and written through to the server because the coach reads the series and a
/// percent_bw prescription is frozen against it.
@Riverpod(keepAlive: true, name: 'bodyweightProvider')
class BodyweightController extends _$BodyweightController {
  late BodyweightRepository _repository;

  @override
  Future<double?> build() async {
    _repository = ref.watch(bodyweightRepositoryProvider);

    // The bodyweight describes an athlete, not a device. Keeping it across a
    // sign out would resolve the next user %BW loads against someone else.
    if (isSignedOut(await settledAuth(ref))) {
      await _repository.clear();
      return null;
    }
    final cached = await _repository.cached();
    _send();
    return cached;
  }

  /// Records [kilograms] as measured now. Returns as soon as the device holds
  /// it: the caller is usually on its way into a run, and a run must not wait
  /// on a network round trip. The send follows on its own.
  Future<void> set(double kilograms) async {
    await _repository.record(kilograms);
    if (ref.mounted) state = AsyncData(kilograms);
    _send();
  }

  Future<void> clear() async {
    await _repository.clear();
    if (ref.mounted) state = const AsyncData(null);
    if (ref.mounted) ref.invalidate(bodyweightPendingProvider);
  }

  /// Sends whatever is waiting, without making the caller wait for it. Errors
  /// are swallowed by the repository, and anything the storage itself throws is
  /// caught here rather than landing on the zone from a provider build.
  void _send() {
    unawaited(
      _repository.flushPending().catchError((_) {}).whenComplete(() {
        if (ref.mounted) ref.invalidate(bodyweightPendingProvider);
      }),
    );
  }
}

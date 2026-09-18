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
    // A measurement taken with no network is filed now there is one, so the
    // coach is not left reading a series with a hole where a session is.
    unawaited(_repository.flushPending());
    return cached;
  }

  /// Records [kilograms] as measured now. Answers whether the server has it, so
  /// a caller can tell the athlete their coach cannot see it yet.
  Future<bool> set(double kilograms) async {
    final sent = await _repository.record(kilograms);
    if (ref.mounted) state = AsyncData(kilograms);
    return sent;
  }

  Future<void> clear() async {
    await _repository.clear();
    if (ref.mounted) state = const AsyncData(null);
  }
}

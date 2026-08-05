import 'package:crimpy/models/auth_models.dart' as auth_models;
import 'package:crimpy/services/bodyweight_service.dart';
import 'package:crimpy/viewmodels/auth_view_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bodyweight_view_model.g.dart';

@Riverpod(keepAlive: true)
BodyweightService bodyweightService(Ref ref) => BodyweightService();

/// The athlete bodyweight in kilograms, null until it is entered or measured.
@Riverpod(keepAlive: true, name: 'bodyweightProvider')
class BodyweightController extends _$BodyweightController {
  late BodyweightService _service;

  @override
  Future<double?> build() async {
    _service = ref.watch(bodyweightServiceProvider);

    // The bodyweight describes an athlete, not a device. Keeping it across a
    // sign out would resolve the next user %BW loads against someone else.
    if (isSignedOut(await _settledAuth())) {
      await _service.clear();
      return null;
    }
    return _service.load();
  }

  /// The auth state once it has stopped loading. Answering while it is still
  /// pending, which it is on every cold start, would resolve this provider and
  /// then immediately rebuild it, stranding whoever awaited the first future.
  Future<AsyncValue<auth_models.User?>> _settledAuth() async {
    try {
      return AsyncData(await ref.watch(authStateProvider.future));
    } catch (error, stackTrace) {
      return AsyncError(error, stackTrace);
    }
  }

  Future<void> set(double kilograms) async {
    await _service.save(kilograms);
    state = AsyncData(kilograms);
  }

  Future<void> clear() async {
    await _service.clear();
    state = const AsyncData(null);
  }
}

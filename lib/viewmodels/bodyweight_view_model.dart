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
    if (isSignedOut(await settledAuth(ref))) {
      await _service.clear();
      return null;
    }
    return _service.load();
  }

  Future<void> set(double kilograms) async {
    await _service.save(kilograms);
    if (ref.mounted) state = AsyncData(kilograms);
  }

  Future<void> clear() async {
    await _service.clear();
    if (ref.mounted) state = const AsyncData(null);
  }
}

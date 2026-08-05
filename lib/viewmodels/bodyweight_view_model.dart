import 'package:crimpy/services/bodyweight_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bodyweight_view_model.g.dart';

@Riverpod(keepAlive: true)
BodyweightService bodyweightService(Ref ref) => BodyweightService();

/// The athlete bodyweight in kilograms, null until it is entered or measured.
@Riverpod(keepAlive: true, name: 'bodyweightProvider')
class BodyweightController extends _$BodyweightController {
  late BodyweightService _service;

  @override
  Future<double?> build() {
    _service = ref.watch(bodyweightServiceProvider);
    return _service.load();
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

import 'package:crimpy/models/run_screen_style.dart';
import 'package:crimpy/services/run_screen_style_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'run_screen_style_view_model.g.dart';

@Riverpod(keepAlive: true)
RunScreenStyleService runScreenStyleService(Ref ref) => RunScreenStyleService();

/// Layout the run screen draws, falling back to [RunScreenStyle.fallback]
/// while it is still being read off the device.
@Riverpod(keepAlive: true, name: 'runScreenStyleProvider')
class RunScreenStyleController extends _$RunScreenStyleController {
  late RunScreenStyleService _service;

  @override
  Future<RunScreenStyle> build() async {
    _service = ref.watch(runScreenStyleServiceProvider);
    return _service.load();
  }

  Future<void> set(RunScreenStyle style) async {
    await _service.save(style);
    if (ref.mounted) state = AsyncData(style);
  }
}

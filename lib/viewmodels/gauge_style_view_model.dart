import 'package:crimpy/models/gauge_style.dart';
import 'package:crimpy/services/gauge_style_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'gauge_style_view_model.g.dart';

@Riverpod(keepAlive: true)
GaugeStyleService gaugeStyleService(Ref ref) => GaugeStyleService();

/// Gauge design the run screen draws, falling back to [GaugeStyle.fallback]
/// while it is still being read off the device.
@Riverpod(keepAlive: true, name: 'gaugeStyleProvider')
class GaugeStyleController extends _$GaugeStyleController {
  late GaugeStyleService _service;

  @override
  Future<GaugeStyle> build() async {
    _service = ref.watch(gaugeStyleServiceProvider);
    return _service.load();
  }

  Future<void> set(GaugeStyle style) async {
    await _service.save(style);
    if (ref.mounted) state = AsyncData(style);
  }
}

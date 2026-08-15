import 'package:crimpy/models/gauge_style.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Device-local storage for the gauge design the run screen draws. It describes
/// a screen the athlete reads, not an account, so it stays on the device.
class GaugeStyleService {
  static const String _gaugeStyleKey = 'gauge_style';

  Future<GaugeStyle> load() async {
    final prefs = await SharedPreferences.getInstance();
    return GaugeStyle.fromName(prefs.getString(_gaugeStyleKey));
  }

  Future<void> save(GaugeStyle style) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_gaugeStyleKey, style.name);
  }
}

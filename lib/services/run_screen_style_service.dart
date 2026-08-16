import 'package:crimpy/models/run_screen_style.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Device-local storage for the run screen layout. It describes a screen the
/// athlete reads, not an account, so it stays on the device.
class RunScreenStyleService {
  static const String _runScreenStyleKey = 'run_screen_style';

  Future<RunScreenStyle> load() async {
    final prefs = await SharedPreferences.getInstance();
    return RunScreenStyle.fromStorageKey(prefs.getString(_runScreenStyleKey));
  }

  Future<void> save(RunScreenStyle style) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_runScreenStyleKey, style.storageKey);
  }
}

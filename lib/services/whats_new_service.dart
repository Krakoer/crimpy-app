import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WhatsNewManager {
  static const String _lastVersionKey = 'last_version_shown';

  /// Check if we should show the "What's New" dialog
  /// Returns true if the app has been updated since last launch
  Future<bool> shouldShowWhatsNew() async {
    final prefs = await SharedPreferences.getInstance();
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
    final lastVersion = prefs.getString(_lastVersionKey);

    // Show if this is a new version or first install
    return lastVersion != currentVersion;
  }

  /// Mark the current version as seen
  Future<void> markVersionSeen() async {
    final prefs = await SharedPreferences.getInstance();
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
    await prefs.setString(_lastVersionKey, currentVersion);
  }

  /// Get the last version that was shown
  Future<String?> getLastVersionShown() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastVersionKey);
  }
}

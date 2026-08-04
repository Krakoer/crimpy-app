import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'app_info_view_model.g.dart';

/// Model to hold app information
class AppInfo {
  final String version;
  final String buildNumber;
  final String appName;
  final String packageName;

  AppInfo({
    required this.version,
    required this.buildNumber,
    required this.appName,
    required this.packageName,
  });

  String get fullVersion => '$version+$buildNumber';
}

/// Provider that returns app information
@Riverpod(keepAlive: true)
Future<AppInfo> appInfo(Ref ref) async {
  final packageInfo = await PackageInfo.fromPlatform();
  return AppInfo(
    version: packageInfo.version,
    buildNumber: packageInfo.buildNumber,
    appName: packageInfo.appName,
    packageName: packageInfo.packageName,
  );
}

/// Provider for managing "What's New" dialog state
@Riverpod(keepAlive: true)
WhatsNewManager whatsNew(Ref ref) {
  return WhatsNewManager();
}

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

import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:crimpy/models/app_info.dart';
import 'package:crimpy/services/whats_new_service.dart';

part 'app_info_view_model.g.dart';

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

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

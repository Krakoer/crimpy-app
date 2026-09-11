import 'package:crimpy/logger.dart';
import 'package:crimpy/utils/video_link.dart';
import 'package:url_launcher/url_launcher.dart';

/// Hands a demo video to whatever the device opens links with. Behind a class so
/// a test can answer for the platform, which no test binding does.
class VideoLauncher {
  const VideoLauncher();

  /// Answers whether the link could be handed over, so a caller can say so
  /// rather than leave a dead tap.
  Future<bool> open(String? link) async {
    final uri = videoLinkUri(link);
    if (uri == null) return false;
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      AppLoggerHelper.warning('Could not open the exercise video $uri: $e');
      return false;
    }
  }
}

/// The launcher the buttons use. Replaced in tests, which have no browser to be
/// sent to and would otherwise hit a missing plugin.
VideoLauncher gVideoLauncher = const VideoLauncher();

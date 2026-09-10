import 'package:crimpy/logger.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

/// Whether [link] is something a browser can be sent to. A coach types this
/// field by hand, so anything else is treated as no video at all rather than
/// offered and then failing on tap.
bool isPlayableVideoLink(String? link) => videoLinkUri(link) != null;

/// The url of a demo video, or null when the coach left the field empty or
/// filled it with something that is not an http address.
Uri? videoLinkUri(String? link) {
  final trimmed = link?.trim() ?? '';
  if (trimmed.isEmpty) return null;
  final uri = Uri.tryParse(trimmed);
  if (uri == null || !uri.hasAuthority) return null;
  return (uri.scheme == 'http' || uri.scheme == 'https') ? uri : null;
}

/// Opens a demo video outside the app. Answers whether it could be handed over,
/// so a caller can say so rather than leave a dead tap.
Future<bool> openVideoLink(String? link) async {
  final uri = videoLinkUri(link);
  if (uri == null) return false;
  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (e) {
    AppLoggerHelper.warning('Could not open the exercise video $uri: $e');
    return false;
  }
}

/// Button onto the coach's demo video for a movement. Renders nothing when the
/// exercise carries no usable link, so a caller can place it unconditionally.
class ExerciseVideoButton extends StatelessWidget {
  final String? link;

  /// Shrinks the button for the run screen, where it sits among steps rather
  /// than in a list of exercises.
  final bool compact;

  const ExerciseVideoButton(this.link, {this.compact = false, super.key});

  @override
  Widget build(BuildContext context) {
    if (!isPlayableVideoLink(link)) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () => _open(context),
        icon: FaIcon(
          FontAwesomeIcons.circlePlay,
          size: compact ? 12 : 13,
          color: CrimpyTheme.primaryOrange,
        ),
        label: Text(
          'WATCH DEMO',
          style: TextStyle(
            fontFamily: 'JetBrainsMono',
            fontSize: compact ? 10.5 : 11.5,
            fontWeight: FontWeight.w700,
            color: CrimpyTheme.primaryOrange,
          ),
        ),
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 8 : 10,
            vertical: compact ? 4 : 6,
          ),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }

  Future<void> _open(BuildContext context) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (await openVideoLink(link)) return;
    messenger?.showSnackBar(
      const SnackBar(content: Text('Could not open the video')),
    );
  }
}

/// How the coach described the movement, shown under the exercise name. Renders
/// nothing when there is no description.
class ExerciseDescription extends StatelessWidget {
  final String? description;

  const ExerciseDescription(this.description, {super.key});

  @override
  Widget build(BuildContext context) {
    final text = description?.trim() ?? '';
    if (text.isEmpty) return const SizedBox.shrink();

    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'JetBrainsMono',
        fontSize: 11,
        height: 1.4,
        color: CrimpyTheme.textMuted,
      ),
    );
  }
}

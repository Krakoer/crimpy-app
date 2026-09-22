import 'package:crimpy/services/video_launcher.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/utils/video_link.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Button onto the coach's demo video for a movement. Renders nothing when the
/// exercise carries no usable link, so a caller can place it unconditionally.
///
/// It shrink wraps and leaves its own placement to the caller: the run screen
/// centres its steps, the training tile left aligns them, and a button that
/// picked one would be wrong on the other.
class ExerciseVideoButton extends StatelessWidget {
  final String? link;

  /// Shrinks the button for the run screen, where it sits among steps rather
  /// than in a list of exercises.
  final bool compact;

  const ExerciseVideoButton(this.link, {this.compact = false, super.key});

  @override
  Widget build(BuildContext context) {
    if (!isPlayableVideoLink(link)) return const SizedBox.shrink();

    return TextButton.icon(
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
          color: CrimpyTheme.textOn(CrimpyTheme.primaryOrange),
        ),
      ),
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 10,
          vertical: compact ? 8 : 10,
        ),
        minimumSize: Size.zero,
        // The run screen keeps the shrink wrapped button so it does not push the
        // step layout around, but not a tiny one: it sits in the centred content
        // with a gap to the controls below, so the risk is not an accidental tap
        // but a deliberate one missed with chalked hands between sets.
        tapTargetSize: compact
            ? MaterialTapTargetSize.shrinkWrap
            : MaterialTapTargetSize.padded,
      ),
    );
  }

  Future<void> _open(BuildContext context) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (await gVideoLauncher.open(link)) return;
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

import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:flutter/material.dart';

/// The box of a timed assessment run that tells the athlete what to do and
/// counts it down, filled with the phase the step is in.
///
/// No Opacity wrapper. It composited the white label and the darkened fill
/// together, so fillOn bought 2.80:1 rather than the 4.93:1 it measures alone,
/// still under the 3:1 these large labels answer to. The box has a hard border
/// and a shadow and was not relying on the fade.
class AssessmentCueBox extends StatelessWidget {
  const AssessmentCueBox({
    required this.phase,
    required this.prompt,
    required this.secondsRemaining,
    super.key,
  });

  final RunPhase phase;
  final String prompt;
  final int secondsRemaining;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: EdgeInsets.all(CrimpyTheme.spaceSm),
      decoration: CrimpyTheme.raised.copyWith(
        color: CrimpyTheme.fillOn(CrimpyTheme.phaseColor(phase)),
      ),
      child: Column(
        children: [
          Text(
            prompt,
            style: CrimpyTheme.headline.copyWith(color: CrimpyTheme.textOnFill),
            textAlign: TextAlign.center,
          ),
          Text(
            '$secondsRemaining',
            style: CrimpyTheme.numerals(
              48,
            ).copyWith(color: CrimpyTheme.textOnFill),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

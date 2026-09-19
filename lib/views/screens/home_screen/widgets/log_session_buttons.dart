import 'package:crimpy/models/common.dart';
import 'package:crimpy/views/screens/home_screen/log_session_screen.dart';
import 'package:crimpy/views/screens/home_screen/widgets/home_card.dart';
import 'package:flutter/material.dart';
import 'package:crimpy/theme/crimpy_theme.dart';

/// One activity offered on the card, with the icon it is drawn with.
typedef _LoggableActivity = ({SessionActivity activity, IconData icon});

/// Every activity a session can be logged under. Hangboard is offered like the
/// rest: a hangboard session done without the sensor is still a hangboard
/// session, and without this it could only be logged as something it is not.
const List<_LoggableActivity> _activities = [
  (activity: SessionActivity.hangboard, icon: Icons.back_hand),
  (activity: SessionActivity.climbing, icon: Icons.terrain),
  (activity: SessionActivity.stretching, icon: Icons.self_improvement),
  (activity: SessionActivity.workout, icon: Icons.fitness_center),
  // Catches everything the others do not, a run in particular.
  (activity: SessionActivity.other, icon: Icons.directions_run),
];

const int _columns = 3;

class LogSessionButtons extends StatelessWidget {
  const LogSessionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return HomeCard(
      title: "Log Session",
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        // Laid out in rows of three rather than one row of five: at five the
        // buttons are narrower than the longest activity name and the labels
        // wrap mid word on a phone.
        child: Column(
          children: [
            for (var first = 0; first < _activities.length; first += _columns)
              Padding(
                padding: EdgeInsets.only(top: first == 0 ? 0 : 8),
                child: Row(
                  children: [
                    for (var column = 0; column < _columns; column++) ...[
                      if (column > 0) const SizedBox(width: 8),
                      Expanded(
                        // The last row is padded with empty cells, so every
                        // button keeps the width the full rows give it.
                        child: first + column < _activities.length
                            ? _SessionActivityButton(
                                activity: _activities[first + column].activity,
                                icon: _activities[first + column].icon,
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SessionActivityButton extends StatelessWidget {
  final SessionActivity activity;
  final IconData icon;

  const _SessionActivityButton({required this.activity, required this.icon});

  @override
  Widget build(BuildContext context) {
    final color = CrimpyTheme.activityColor(activity);

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => LogSessionScreen(activity: activity),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 2),
          color: color.withValues(alpha: 0.1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              activity.displayName,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

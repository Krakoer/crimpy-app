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

/// Logging records something done away from the app, so it sits last on the
/// home screen as one row of icons rather than as tiles that outweigh the
/// trainings above it. Each icon names its activity in its tooltip, which is
/// also what a screen reader announces. See Krakoer/crimpy#165.
class LogSessionButtons extends StatelessWidget {
  const LogSessionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return HomeCard(
      title: "Log a session",
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (final loggable in _activities)
            _SessionActivityButton(
              activity: loggable.activity,
              icon: loggable.icon,
            ),
        ],
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
    // The activity shows in the icon only; the button itself stays neutral.
    // See Krakoer/crimpy#170.
    return IconButton(
      tooltip: 'Log ${activity.displayName}',
      icon: Icon(icon, size: 28),
      color: CrimpyTheme.markOn(CrimpyTheme.activityColor(activity)),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => LogSessionScreen(activity: activity),
          ),
        );
      },
    );
  }
}

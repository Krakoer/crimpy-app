import 'package:crimpy/models/common.dart';
import 'package:crimpy/views/screens/home_screen/log_session_screen.dart';
import 'package:crimpy/views/screens/home_screen/widgets/home_card.dart';
import 'package:flutter/material.dart';

class LogSessionButtons extends StatelessWidget {
  const LogSessionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return HomeCard(
      title: "Log Session",
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: _SessionActivityButton(
                activity: SessionActivity.climbing,
                icon: Icons.terrain,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _SessionActivityButton(
                activity: SessionActivity.stretching,
                icon: Icons.self_improvement,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _SessionActivityButton(
                activity: SessionActivity.workout,
                icon: Icons.fitness_center,
              ),
            ),
            const SizedBox(width: 8),
            // Catches everything the other three do not, a run in particular.
            Expanded(
              child: _SessionActivityButton(
                activity: SessionActivity.other,
                icon: Icons.directions_run,
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
    final color = Color(activity.colorValue);

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

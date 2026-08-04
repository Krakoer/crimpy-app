import 'package:flutter/material.dart';

/// Tells a running workout screen when the app leaves and returns to the
/// foreground.
///
/// A run cannot be left unattended: the workout clock stops being pumped while
/// the app is in the background, while the sensor keeps streaming samples, so
/// the two drift apart by however long the user was away. Screens react to that
/// explicitly instead of silently going out of step.
mixin WorkoutLifecycleMixin<T extends StatefulWidget> on State<T> {
  late final _WorkoutLifecycleObserver _lifecycleObserver;

  /// The app left the foreground while this screen was on top.
  void onLeftForeground();

  /// The app came back after a call to [onLeftForeground].
  void onReturnedToForeground();

  @override
  void initState() {
    super.initState();
    _lifecycleObserver = _WorkoutLifecycleObserver(
      onLeft: () {
        if (mounted) onLeftForeground();
      },
      onReturned: () {
        if (mounted) onReturnedToForeground();
      },
    );
    WidgetsBinding.instance.addObserver(_lifecycleObserver);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_lifecycleObserver);
    super.dispose();
  }
}

class _WorkoutLifecycleObserver with WidgetsBindingObserver {
  _WorkoutLifecycleObserver({required this.onLeft, required this.onReturned});

  final VoidCallback onLeft;
  final VoidCallback onReturned;

  var _away = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        if (!_away) {
          _away = true;
          onLeft();
        }
      case AppLifecycleState.resumed:
        if (_away) {
          _away = false;
          onReturned();
        }
      case AppLifecycleState.inactive:
        // Transient: the notification shade, an incoming call banner, the app
        // switcher. The run is still on screen, so it keeps going.
        break;
    }
  }
}

/// Holds the run until the user is back in position. Completes once they resume.
Future<void> showWorkoutPausedDialog(BuildContext context) => showDialog<void>(
  context: context,
  barrierDismissible: false,
  builder: (ctx) => PopScope(
    canPop: false,
    child: AlertDialog(
      title: const Text('Workout paused'),
      content: const Text(
        'The app went to the background, so the workout was paused and the '
        'sensor stopped recording. Get back in position, then resume.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Resume'),
        ),
      ],
    ),
  ),
);

/// Tells the user an assessment cannot be salvaged. Completes when dismissed.
Future<void> showAssessmentInterruptedDialog(
  BuildContext context, {
  required String reason,
}) => showDialog<void>(
  context: context,
  barrierDismissible: false,
  builder: (ctx) => PopScope(
    canPop: false,
    child: AlertDialog(
      title: const Text('Assessment interrupted'),
      content: Text(
        'The app went to the background during the assessment, so it has been '
        'stopped and nothing was saved.\n\n$reason',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Back'),
        ),
      ],
    ),
  ),
);

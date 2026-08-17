import 'package:crimpy/repositories/ble_repository.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tells a running workout screen when the app leaves and returns to the
/// foreground, and owns the sensor stream while it is on screen.
///
/// A run cannot be left unattended: the workout clock stops being pumped while
/// the app is in the background, while the sensor keeps streaming samples, so
/// the two drift apart by however long the user was away. Screens react to that
/// explicitly instead of silently going out of step.
///
/// A run is also the only thing that ever pauses the stream, so it is the only
/// thing that can hand it back. That happens here rather than in each screen,
/// so a run that is left in any state, including from under a dialog, cannot
/// leave the sensor mute for the live gauge, the bodyweight measure and the
/// next run.
mixin WorkoutLifecycleMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  late final _WorkoutLifecycleObserver _lifecycleObserver;

  /// Held from `initState` because reading a provider during dispose, which is
  /// where the stream is handed back, is not allowed.
  late final BleRepository sensorRepository;

  late NavigatorState _navigator;
  ModalRoute<dynamic>? _runRoute;

  bool _handlingReturn = false;

  /// The navigator the run sits on. Held so it can still be used after an
  /// await, where the run's own context may already be gone.
  NavigatorState get runNavigator => _navigator;

  /// The app left the foreground while this screen was on top.
  void onLeftForeground();

  /// The app came back after a call to [onLeftForeground].
  Future<void> onReturnedToForeground();

  /// Brings the run back to the top of the navigator, closing the tutorial or
  /// the leave confirmation if the user left one of them over it. Both sit on
  /// the same navigator as the run, so a dialog shown from an interruption
  /// would otherwise stack on top of them and be answered for a run that is
  /// still covered.
  void popDownToRun() {
    _navigator.popUntil((route) => route == _runRoute || route.isFirst);
  }

  @override
  void initState() {
    super.initState();
    sensorRepository = ref.read(bleRepositoryProvider);
    _lifecycleObserver = _WorkoutLifecycleObserver(
      onLeft: () {
        if (mounted) onLeftForeground();
      },
      onReturned: _handleReturnToForeground,
    );
    WidgetsBinding.instance.addObserver(_lifecycleObserver);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _navigator = Navigator.of(context);
    _runRoute = ModalRoute.of(context);
  }

  /// The app can leave the foreground again while a return is still being
  /// handled, and the dialog that return put up is still the one the user has
  /// to answer. Handling the second return would pop that dialog down with
  /// everything else covering the run, which completes it as if it had been
  /// answered and resumes the run with no one asking for it.
  Future<void> _handleReturnToForeground() async {
    if (!mounted || _handlingReturn) return;
    _handlingReturn = true;
    try {
      await onReturnedToForeground();
    } finally {
      _handlingReturn = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_lifecycleObserver);
    sensorRepository.resumeStreaming();
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

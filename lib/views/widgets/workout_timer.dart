import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:crimpy/models/training_execution_model.dart';

/// Wrapper around StopWatch that allows to skip time.
class CrimpyWatch {
  final watch = Stopwatch();
  Duration _skipped = Duration.zero;

  int get elapsedMilliseconds =>
      watch.elapsedMilliseconds + _skipped.inMilliseconds;

  void start() {
    watch.start();
  }

  void stop() {
    watch.stop();
  }

  void skip(int millis) {
    _skipped += Duration(milliseconds: millis);
  }
}

/// A [CrimpyWatch] whose time is set by hand, so tests can step across rep
/// boundaries exactly instead of racing a real clock.
class ManualCrimpyWatch extends CrimpyWatch {
  int _elapsed = 0;

  @override
  int get elapsedMilliseconds => _elapsed;

  /// Moves time forward by [millis].
  void advance(int millis) => _elapsed += millis;

  @override
  void start() {}

  @override
  void stop() {}

  @override
  void skip(int millis) => _elapsed += millis;
}

/// Drives a workout: walks the execution items in order, counting each one
/// down and reporting transitions.
class WorkoutTimer {
  WorkoutTimer({
    this.onTick,
    this.onNextRep,
    this.onSecondChange,
    this.onFinished,
    required this.items,
    this.playSound = false,
    CrimpyWatch? watch,
  }) : _stopwatch = watch ?? CrimpyWatch();

  final void Function()? onTick;
  final void Function(int)? onNextRep;
  final void Function()? onSecondChange;
  final Future<void> Function()? onFinished;
  final List<TrainingExecutionItem> items;
  final bool playSound;

  final CrimpyWatch _stopwatch;

  var elaspedTime = 0;
  var currentItemIndex = 0;
  var finished = false;
  var startCurrentRep = 0;
  var isRunning = false;
  var repCount = 0;
  // Only created when the workout actually plays sound: allocating audio
  // players otherwise reaches for platform channels that need not be involved.
  AudioPlayer? _playerBip;
  AudioPlayer? _playerBiiip;

  late Timer timer;

  void init() {
    if (playSound) {
      // Load the sound file in cache
      _playerBip = AudioPlayer();
      _playerBip!.setSource(AssetSource('beep-07a.mp3'));
      _playerBip!.setReleaseMode(ReleaseMode.stop);
      _playerBiiip = AudioPlayer();
      _playerBiiip!.setSource(AssetSource('beep-09.mp3'));
      _playerBiiip!.setReleaseMode(ReleaseMode.stop);
    }
    timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      onTick?.call();

      final secondChanged =
          elaspedTime < _stopwatch.elapsedMilliseconds ~/ 1000;
      if (secondChanged) {
        elaspedTime = _stopwatch.elapsedMilliseconds ~/ 1000;
      }

      // The rep is advanced before anything is reported, so callbacks always
      // observe the rep that is actually current. Reporting first made the tick
      // that ends a rep announce the outgoing one with zero seconds left, which
      // is what put a stray "0" on screen before the next rep appeared.
      // The boundary is inclusive for the same reason: the tick that brings the
      // countdown to zero is the one that moves on.
      // Self-paced steps never advance on time; the user taps "Done".
      var advanced = false;
      if (currentItem is! ConfirmItem &&
          _stopwatch.elapsedMilliseconds >=
              startCurrentRep + currentItem.durationSeconds * 1000) {
        if (playSound && currentItemIndex < items.length - 1) {
          _playerBiiip?.resume();
        }
        _advance(() => startCurrentRep + currentItem.durationSeconds * 1000);
        advanced = true;
      }

      if (secondChanged && !advanced) {
        // A rep change already reported itself from within _advance, and its
        // transition tone stands in for the countdown beep on that tick.
        onSecondChange?.call();
        if (playSound && [3, 2, 1].contains(currentItemRemaining)) {
          _playerBip?.resume();
        }
      }
    });
  }

  /// Moves to the next item, or finishes the workout when the current one is
  /// the last. `nextStart` gives the reference point the following rep counts
  /// down from, evaluated before the index moves.
  void _advance(int Function() nextStart) {
    if (currentItem is! RestItem) {
      repCount += 1;
    }

    if (currentItemIndex >= items.length - 1) {
      _stopwatch.stop();
      timer.cancel();
      finished = true;
      onFinished?.call();
      return;
    }

    startCurrentRep = nextStart();
    onNextRep?.call(nextItem!.durationSeconds);
    currentItemIndex += 1;
    // A transition does not always coincide with a second change: skipping or
    // confirming a rep moves the reference point mid-second. Repaint here so
    // the new rep is shown immediately instead of leaving the previous value
    // on screen until the next second elapses.
    onSecondChange?.call();
  }

  /// Advance from a self-paced confirm step once the user marks it done.
  void confirmRep() {
    _advance(() => _stopwatch.elapsedMilliseconds);
  }

  void skipRep() {
    if (currentItemIndex < items.length - 1) {
      _stopwatch.skip(
        currentItem.durationSeconds * 1000 -
            (_stopwatch.elapsedMilliseconds - startCurrentRep),
      );
    }
    _advance(() => _stopwatch.elapsedMilliseconds);
  }

  int get elapsedMilliseconds => _stopwatch.elapsedMilliseconds;

  TrainingExecutionItem get currentItem {
    return items[currentItemIndex];
  }

  TrainingExecutionItem? get nextItem {
    if (currentItemIndex < items.length - 1) {
      return items[currentItemIndex + 1];
    } else {
      return null;
    }
  }

  /// Whole seconds left in the current item, counting down to 1 and never to 0:
  /// reaching zero is the moment the item ends, and that frame belongs to the
  /// next one.
  int get currentItemRemaining {
    final remainingMs =
        startCurrentRep +
        currentItem.durationSeconds * 1000 -
        _stopwatch.elapsedMilliseconds;
    if (remainingMs <= 0) return 0;
    return (remainingMs / 1000).ceil();
  }

  void play() {
    _stopwatch.start();
    isRunning = true;
  }

  void stop() {
    _stopwatch.stop();
    isRunning = false;
  }

  void dispose() {
    timer.cancel();
    _playerBip?.dispose();
    _playerBiiip?.dispose();
  }
}

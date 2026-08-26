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

  /// When the emom round the run is inside started, in stopwatch milliseconds.
  /// The rest that closes a round is measured back to it rather than run for a
  /// fixed length, so the round after it starts on the clock however long the
  /// self paced work of this one took.
  var _roundStartedAt = 0;
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
              startCurrentRep + currentItemDuration * 1000) {
        if (playSound && currentItemIndex < items.length - 1) {
          _playerBiiip?.resume();
        }
        _advance(() => startCurrentRep + currentItemDuration * 1000);
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
    final entering = nextItem!;
    // Read off the round the step belongs to rather than a flag stamped on it,
    // so a step opening a round is whatever the expander happened to lay down
    // first and nothing has to be copied onto it.
    if (!(entering.emom?.isSameRoundAs(currentItem.emom) ?? false)) {
      _roundStartedAt = startCurrentRep;
    }
    onNextRep?.call(_durationAt(currentItemIndex + 1, startCurrentRep));
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
        currentItemDuration * 1000 -
            (_stopwatch.elapsedMilliseconds - startCurrentRep),
      );
    }
    _advance(() => _stopwatch.elapsedMilliseconds);
  }

  /// Drops every step still queued after the current one that belongs to
  /// [blockKey], which is how an emom the athlete dropped out of ends where
  /// they stopped instead of playing out rounds they will not do. The steps
  /// already played keep their indices, so nothing recorded moves.
  void dropRemainingBlock(String blockKey) {
    var end = currentItemIndex + 1;
    while (end < items.length && items[end].emom?.blockKey == blockKey) {
      end++;
    }
    if (end > currentItemIndex + 1) {
      items.removeRange(currentItemIndex + 1, end);
    }
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

  /// How long the step the run is on lasts. Every step but the rest closing an
  /// emom round runs for the length it was expanded with.
  int get currentItemDuration => _durationAt(currentItemIndex, startCurrentRep);

  /// How long the step at [index] lasts, given that it starts at [startsAt].
  /// The rest closing an emom round runs to the mark on the clock the next
  /// round starts on, so it is measured back to the step its round opened on
  /// rather than taken as the length it was laid down with.
  int _durationAt(int index, int startsAt) {
    final item = items[index];
    if (item is! IntervalRestItem) return item.durationSeconds;
    final worked = (startsAt - _roundStartedAt) ~/ 1000;
    return (item.intervalSeconds - worked).clamp(0, item.intervalSeconds);
  }

  /// Whole seconds left in the current item, counting down to 1 and never to 0:
  /// reaching zero is the moment the item ends, and that frame belongs to the
  /// next one.
  int get currentItemRemaining {
    final remainingMs =
        startCurrentRep +
        currentItemDuration * 1000 -
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

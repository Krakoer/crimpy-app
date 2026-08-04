import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:crimpy/models/training_model.dart';

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

/// Timer that manages the logic of repetitions in workout.
/// This timer exposes callbacks to be called on rep changes, on second changes and on training finish.
class WorkoutTimer {
  WorkoutTimer({
    this.onTick,
    this.onNextRep,
    this.onSecondChange,
    this.onFinished,
    required this.repetitions,
    this.playSound = false,
  });

  final void Function()? onTick;
  final void Function(int)? onNextRep;
  final void Function()? onSecondChange;
  final Future<void> Function()? onFinished;
  final List<RepModel> repetitions;
  final bool playSound;

  final _stopwatch = CrimpyWatch();

  var elaspedTime = 0;
  var currentRepIndex = 0;
  var finished = false;
  var startCurrentRep = 0;
  var isRunning = false;
  var repCount = 0;
  final playerBip = AudioPlayer();
  final playerBiiip = AudioPlayer();

  late Timer timer;

  void init() {
    if (playSound) {
      // Load the sound file in cache
      playerBip.setSource(AssetSource('beep-07a.mp3'));
      playerBip.setReleaseMode(ReleaseMode.stop);
      playerBiiip.setSource(AssetSource('beep-09.mp3'));
      playerBiiip.setReleaseMode(ReleaseMode.stop);
    }
    timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (onTick != null) {
        onTick!();
      }
      // If the second has changed
      if (elaspedTime < _stopwatch.elapsedMilliseconds ~/ 1000) {
        elaspedTime = _stopwatch.elapsedMilliseconds ~/ 1000;
        if (onSecondChange != null) {
          onSecondChange!();
        }
        // Play the sound.
        if (playSound && [3, 2, 1].contains(currentRepRemaining)) {
          playerBip.resume();
        }
      }
      // Self-paced steps never advance on time; the user taps "Done".
      if (!currentRep.isConfirm &&
          _stopwatch.elapsedMilliseconds >
              startCurrentRep + currentRep.durationInSeconds * 1000) {
        if (currentRepIndex < repetitions.length - 1) {
          if (!currentRep.isRest) {
            repCount += 1;
          }
          startCurrentRep += currentRep.durationInSeconds * 1000;
          if (playSound) {
            playerBiiip.resume();
          }
          if (onNextRep != null) {
            onNextRep!(nextRep!.durationInSeconds);
          }
          currentRepIndex += 1;
        } else {
          _stopwatch.stop();
          timer.cancel();
          finished = true;
          if (onFinished != null) {
            onFinished!();
          }
        }
      }
    });
  }

  /// Advance from a self-paced confirm step once the user marks it done.
  void confirmRep() {
    if (currentRepIndex < repetitions.length - 1) {
      if (!currentRep.isRest) {
        repCount += 1;
      }
      startCurrentRep = _stopwatch.elapsedMilliseconds;
      if (onNextRep != null) {
        onNextRep!(nextRep!.durationInSeconds);
      }
      currentRepIndex += 1;
    } else {
      _stopwatch.stop();
      timer.cancel();
      finished = true;
      if (onFinished != null) {
        onFinished!();
      }
    }
  }

  void skipRep() {
    if (currentRepIndex < repetitions.length - 1) {
      if (!currentRep.isRest) {
        repCount += 1;
      }
      _stopwatch.skip(
        currentRep.durationInSeconds * 1000 -
            (_stopwatch.elapsedMilliseconds - startCurrentRep),
      );
      startCurrentRep = _stopwatch.elapsedMilliseconds;
      if (onNextRep != null) {
        onNextRep!(nextRep!.durationInSeconds);
      }
      currentRepIndex += 1;
    } else {
      _stopwatch.stop();
      timer.cancel();
      finished = true;
      if (onFinished != null) {
        onFinished!();
      }
    }
  }

  int get elapsedMilliseconds => _stopwatch.elapsedMilliseconds;

  RepModel get currentRep {
    return repetitions[currentRepIndex];
  }

  RepModel? get nextRep {
    if (currentRepIndex < repetitions.length - 1) {
      return repetitions[currentRepIndex + 1];
    } else {
      return null;
    }
  }

  int get currentRepRemaining {
    return currentRep.durationInSeconds -
        (_stopwatch.elapsedMilliseconds / 1000 - startCurrentRep / 1000)
            .floor();
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
    playerBip.dispose();
    playerBiiip.dispose();
  }
}

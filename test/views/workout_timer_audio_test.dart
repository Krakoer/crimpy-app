import 'package:crimpy/views/widgets/workout_timer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// What the beep players' audio context asks the given platform for.
Map<String, dynamic> beepContextSentOn(TargetPlatform platform) {
  debugDefaultTargetPlatformOverride = platform;
  addTearDown(() => debugDefaultTargetPlatformOverride = null);
  return beepAudioContext.toJson();
}

void main() {
  group('WorkoutTimer beeps', () {
    test('request no audio focus on Android so music keeps playing', () {
      expect(beepContextSentOn(TargetPlatform.android)['audioFocus'], 0);
    });

    test('mix with other apps on iOS instead of interrupting them', () {
      final context = beepContextSentOn(TargetPlatform.iOS);

      expect(context['category'], 'playback');
      expect(context['options'], ['mixWithOthers']);
    });
  });
}

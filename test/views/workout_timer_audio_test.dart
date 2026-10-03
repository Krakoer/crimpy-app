import 'dart:async';
import 'dart:io';

import 'package:crimpy/models/training_execution_model.dart';
import 'package:crimpy/views/widgets/workout_timer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// The calls the timer made, per player, and when they are all in: every
/// player it created has been handed its source.
typedef RecordedPlayerCalls = ({
  Map<String, List<MethodCall>> callsByPlayer,
  Future<void> sourcesSet,
});

/// Stands in for the audioplayers native side and records, per player, the
/// calls the timer makes. Each source reports itself prepared as a real player
/// would, and assets are copied into a scratch directory before being played.
///
/// That copy is real file IO, done by audioplayers' asset cache before it sends
/// the source. It completes outside the event queue a test can pump, so how
/// many turns of the queue it takes depends on the machine's load: the source
/// is waited for by name rather than by pumping.
RecordedPlayerCalls recordPlayerCalls({required int players}) {
  final callsByPlayer = <String, List<MethodCall>>{};
  final sourcesSet = Completer<void>();
  final eventSinks = <String, MockStreamHandlerEventSink>{};
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  final scratch = Directory.systemTemp.createTempSync('beeps');
  addTearDown(() => scratch.deleteSync(recursive: true));
  const pathProvider = MethodChannel('plugins.flutter.io/path_provider');
  messenger.setMockMethodCallHandler(pathProvider, (_) async => scratch.path);
  addTearDown(() => messenger.setMockMethodCallHandler(pathProvider, null));

  const playersChannel = MethodChannel('xyz.luan/audioplayers');
  messenger.setMockMethodCallHandler(playersChannel, (call) async {
    final playerId = (call.arguments as Map)['playerId'] as String;
    callsByPlayer.putIfAbsent(playerId, () => []).add(call);
    if (call.method == 'create') {
      final events = EventChannel('xyz.luan/audioplayers/events/$playerId');
      messenger.setMockStreamHandler(
        events,
        MockStreamHandler.inline(
          onListen: (_, sink) => eventSinks[playerId] = sink,
        ),
      );
      addTearDown(() => messenger.setMockStreamHandler(events, null));
    }
    if (call.method == 'setSourceUrl') {
      eventSinks[playerId]?.success({
        'event': 'audio.onPrepared',
        'value': true,
      });
      final withSource = callsByPlayer.values.where(
        (calls) => calls.any((c) => c.method == 'setSourceUrl'),
      );
      if (withSource.length == players && !sourcesSet.isCompleted) {
        sourcesSet.complete();
      }
    }
    return null;
  });
  addTearDown(() => messenger.setMockMethodCallHandler(playersChannel, null));

  const global = MethodChannel('xyz.luan/audioplayers.global');
  messenger.setMockMethodCallHandler(global, (_) async => null);
  addTearDown(() => messenger.setMockMethodCallHandler(global, null));

  return (callsByPlayer: callsByPlayer, sourcesSet: sourcesSet.future);
}

/// The timer's two players, a short and a long beep.
const _beepPlayers = 2;

Future<Map<String, List<MethodCall>>> playerCallsOn(
  TargetPlatform platform,
) async {
  debugDefaultTargetPlatformOverride = platform;
  addTearDown(() => debugDefaultTargetPlatformOverride = null);
  final recorded = recordPlayerCalls(players: _beepPlayers);

  final timer = WorkoutTimer(
    items: [RestItem(durationSeconds: 5)],
    playSound: true,
    watch: ManualCrimpyWatch(),
  )..init();
  addTearDown(() async {
    timer.dispose();
    await pumpEventQueue();
  });
  // Bounded, so a timer that never sets a source fails here with a reason
  // rather than hanging the suite. The bound is far past any real copy, and
  // under the test's own 30 s timeout, so the reason is the error reported.
  await recorded.sourcesSet.timeout(
    const Duration(seconds: 10),
    onTimeout: () => fail('The beeps were never given their sources'),
  );

  return recorded.callsByPlayer;
}

/// The audio context a player was given, provided it came before its source:
/// a context set after the source is too late for the first beep.
Map<Object?, Object?>? contextBeforeSource(List<MethodCall> calls) {
  final contextAt = calls.indexWhere((c) => c.method == 'setAudioContext');
  final sourceAt = calls.indexWhere((c) => c.method == 'setSourceUrl');
  if (contextAt < 0 || sourceAt < 0 || contextAt > sourceAt) return null;
  return calls[contextAt].arguments as Map<Object?, Object?>;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WorkoutTimer beeps', () {
    test('request no audio focus on Android so music keeps playing', () async {
      final callsByPlayer = await playerCallsOn(TargetPlatform.android);

      expect(callsByPlayer, hasLength(_beepPlayers));
      for (final calls in callsByPlayer.values) {
        expect(contextBeforeSource(calls)?['audioFocus'], 0);
      }
    });

    test('mix with other apps on iOS instead of interrupting them', () async {
      final callsByPlayer = await playerCallsOn(TargetPlatform.iOS);

      expect(callsByPlayer, hasLength(_beepPlayers));
      for (final calls in callsByPlayer.values) {
        final context = contextBeforeSource(calls);
        expect(context?['category'], 'playback');
        expect(context?['options'], ['mixWithOthers']);
      }
    });
  });
}

import 'dart:io';

import 'package:crimpy/models/training_execution_model.dart';
import 'package:crimpy/views/widgets/workout_timer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Stands in for the audioplayers native side and records, per player, the
/// calls the timer makes. Each source reports itself prepared as a real player
/// would, and assets are copied into a scratch directory before being played.
Map<String, List<MethodCall>> recordPlayerCalls() {
  final callsByPlayer = <String, List<MethodCall>>{};
  final eventSinks = <String, MockStreamHandlerEventSink>{};
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  final scratch = Directory.systemTemp.createTempSync('beeps');
  addTearDown(() => scratch.deleteSync(recursive: true));
  const pathProvider = MethodChannel('plugins.flutter.io/path_provider');
  messenger.setMockMethodCallHandler(pathProvider, (_) async => scratch.path);
  addTearDown(() => messenger.setMockMethodCallHandler(pathProvider, null));

  const players = MethodChannel('xyz.luan/audioplayers');
  messenger.setMockMethodCallHandler(players, (call) async {
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
    }
    return null;
  });
  addTearDown(() => messenger.setMockMethodCallHandler(players, null));

  const global = MethodChannel('xyz.luan/audioplayers.global');
  messenger.setMockMethodCallHandler(global, (_) async => null);
  addTearDown(() => messenger.setMockMethodCallHandler(global, null));

  return callsByPlayer;
}

Future<Map<String, List<MethodCall>>> playerCallsOn(
  TargetPlatform platform,
) async {
  debugDefaultTargetPlatformOverride = platform;
  addTearDown(() => debugDefaultTargetPlatformOverride = null);
  final callsByPlayer = recordPlayerCalls();

  final timer = WorkoutTimer(
    items: [RestItem(durationSeconds: 5)],
    playSound: true,
    watch: ManualCrimpyWatch(),
  )..init();
  addTearDown(() async {
    timer.dispose();
    await pumpEventQueue();
  });
  await pumpEventQueue();

  return callsByPlayer;
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

      expect(callsByPlayer, hasLength(2));
      for (final calls in callsByPlayer.values) {
        expect(contextBeforeSource(calls)?['audioFocus'], 0);
      }
    });

    test('mix with other apps on iOS instead of interrupting them', () async {
      final callsByPlayer = await playerCallsOn(TargetPlatform.iOS);

      expect(callsByPlayer, hasLength(2));
      for (final calls in callsByPlayer.values) {
        final context = contextBeforeSource(calls);
        expect(context?['category'], 'playback');
        expect(context?['options'], ['mixWithOthers']);
      }
    });
  });
}

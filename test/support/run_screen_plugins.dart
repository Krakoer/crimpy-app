import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// The run screen keeps the screen awake and preloads sounds; neither plugin
/// exists in a test binding, so both channels answer with a no-op. Held in one
/// place so a channel a plugin bump renames is fixed once rather than in every
/// test file that pushes a run. Cleared afterwards, so the stubs belong to the
/// test that asked for them.
void stubRunScreenPlugins() {
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  for (final channel in const [
    MethodChannel('dev.fluttercommunity.plus/wakelock'),
    MethodChannel('xyz.luan/audioplayers'),
    MethodChannel('xyz.luan/audioplayers.global'),
  ]) {
    messenger.setMockMethodCallHandler(channel, (call) async => null);
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
  }
}

import 'dart:io';

import 'package:flutter/services.dart';

/// The test font draws every glyph as a square as wide as it is tall, so a
/// layout test would wrap or overflow on text the phone never does. The Roboto
/// the SDK ships is loaded instead, so the widths are the phone's.
///
/// An iOS theme names the Cupertino system families, which a test has no font
/// for either. Roboto stands in for them too, so a layout pumped as iOS is
/// measured with real glyphs; its line heights come from the styles alone, so
/// the stand in moves nothing vertically.
Future<void> loadRoboto() async {
  final fonts =
      '${Platform.environment['FLUTTER_ROOT']}'
      '/bin/cache/artifacts/material_fonts';
  for (final family in const [
    'Roboto',
    'CupertinoSystemText',
    'CupertinoSystemDisplay',
  ]) {
    final loader = FontLoader(family);
    for (final weight in ['Light', 'Regular', 'Medium', 'Bold']) {
      final bytes = File('$fonts/Roboto-$weight.ttf').readAsBytesSync();
      loader.addFont(Future.value(ByteData.sublistView(bytes)));
    }
    await loader.load();
  }
}

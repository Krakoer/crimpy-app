import 'dart:io';

import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/views/screens/home_screen/history/widgets/week_histogram_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// The test font draws every glyph as a square as wide as it is tall, so a
/// three letter day name wraps in a column Roboto fits it in, and a layout
/// test would fail on text the phone never wraps. The Roboto the SDK ships is
/// loaded instead, so the widths are the phone's.
Future<void> loadRoboto() async {
  final fonts =
      '${Platform.environment['FLUTTER_ROOT']}'
      '/bin/cache/artifacts/material_fonts';
  final loader = FontLoader('Roboto');
  for (final weight in ['Regular', 'Medium', 'Bold']) {
    final bytes = File('$fonts/Roboto-$weight.ttf').readAsBytesSync();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
}

void main() {
  setUpAll(loadRoboto);

  final monday = DateTime(2026, 9, 21);

  // The home card's content width on a 360dp phone: the screen's 16dp gutter
  // and the card's 16dp padding and 2dp line on each side.
  const phoneContentWidth = 360.0 - 2 * (16 + 16 + 2);

  Future<void> pumpWeek(WidgetTester tester, Duration onTuesday) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: phoneContentWidth,
              child: WeekHistogramWidget(
                startOfWeek: monday,
                maxBarHeight: 75,
                sessions: [
                  SessionModel(
                    name: 'Bouldering',
                    isAssessment: false,
                    origin: SessionOrigin.logged,
                    activity: SessionActivity.climbing,
                    durationInSeconds: onTuesday.inSeconds,
                    date: DateTime(2026, 9, 22, 18),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('a long day keeps its length on one line inside its column', (
    tester,
  ) async {
    await pumpWeek(tester, const Duration(minutes: 90));

    expect(tester.takeException(), isNull);
    final long = find.text('1 h 30 min');
    expect(long, findsOneWidget);
    final column = tester.getSize(find.byType(Expanded).at(1)).width;
    expect(tester.getRect(long).width, lessThanOrEqualTo(column + 0.01));

    final longParagraph = tester.renderObject<RenderParagraph>(long);
    final shortParagraph = tester.renderObject<RenderParagraph>(
      find.text('0 min').first,
    );
    expect(longParagraph.size.height, shortParagraph.size.height);
  });
}

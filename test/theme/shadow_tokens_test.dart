import 'dart:io';
import 'dart:ui' as ui;

import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// A shadow named outside the theme. The app has two surfaces,
/// CrimpyTheme.raised and CrimpyTheme.flat, and a widget picks one by role
/// rather than casting a shadow of its own: the offset shadow only stands out
/// while few things wear it. A Material elevation above zero casts one too.
/// See Krakoer/crimpy#173.
final RegExp shadowName = RegExp(
  r'\b(BoxShadow|Shadow\(|kElevationToShadow)'
  r'|\belevation:(?!\s*0(\.0+)?\s*(,|\)|$))',
);

const String themeFile = 'lib/theme/crimpy_theme.dart';

void main() {
  test('no file outside the theme names a shadow', () {
    final offences = <String>[];
    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      if (entity.path == themeFile) continue;
      final lines = entity.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (lines[i].trimLeft().startsWith('//')) continue;
        for (final match in shadowName.allMatches(lines[i])) {
          offences.add('${entity.path}:${i + 1} names ${match.group(0)}');
        }
      }
    }
    expect(offences, isEmpty, reason: offences.join('\n'));
  });

  test('the scan recognises a shadow and ignores the theme surfaces', () {
    expect(shadowName.hasMatch('boxShadow: [BoxShadow(color: c)],'), isTrue);
    expect(shadowName.hasMatch('elevation: 2,'), isTrue);
    expect(shadowName.hasMatch('shadows: [Shadow(blurRadius: 4)],'), isTrue);
    expect(shadowName.hasMatch('elevation: 0.5,'), isTrue);
    expect(shadowName.hasMatch('elevation: .5,'), isTrue);
    expect(shadowName.hasMatch('elevation: cardElevation,'), isTrue);
    expect(shadowName.hasMatch('elevation: 0,'), isFalse);
    expect(shadowName.hasMatch('elevation: 0.0,'), isFalse);
    expect(shadowName.hasMatch('elevation: 0)'), isFalse);
    expect(shadowName.hasMatch('decoration: CrimpyTheme.raised,'), isFalse);
    expect(shadowName.hasMatch('decoration: CrimpyTheme.flat,'), isFalse);
  });

  test('raised casts the offset shadow on the card line, flat casts none', () {
    expect(CrimpyTheme.raised.boxShadow, CrimpyTheme.raisedShadow);
    expect(
      CrimpyTheme.raised.border,
      const Border.fromBorderSide(
        BorderSide(color: CrimpyTheme.outline, width: 2),
      ),
    );
    expect(CrimpyTheme.flat.boxShadow, isNull);
    expect(
      (CrimpyTheme.flat.border! as Border).top.width,
      lessThan((CrimpyTheme.raised.border! as Border).top.width),
    );
  });

  // Read off the painted pixels rather than the decoration objects: a shadow
  // can be declared and still be clipped away on its way to the screen, as it
  // is when an ink feature carries it.
  group('the offset shadow reaches the screen', () {
    const cardOrigin = 20.0;
    const cardSize = Size(100, 50);
    final boundaryKey = GlobalKey();

    /// The colour painted inside the shadow's band, just past the card's
    /// bottom right corner, where only the offset shadow can reach.
    Future<Color> paintedInShadowBand(WidgetTester tester, Widget card) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Align(
            alignment: Alignment.topLeft,
            child: RepaintBoundary(
              key: boundaryKey,
              child: Container(
                color: CrimpyTheme.bgPrimary,
                padding: const EdgeInsets.all(cardOrigin),
                child: SizedBox(width: cardSize.width, child: card),
              ),
            ),
          ),
        ),
      );
      final boundary =
          tester.renderObject(find.byKey(boundaryKey)) as RenderRepaintBoundary;
      final bytes = await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 1);
        final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
        final width = image.width;
        image.dispose();
        return (data!, width);
      });
      final (data, width) = bytes!;
      final x = (cardOrigin + cardSize.width + CrimpyTheme.raisedOffset - 1)
          .toInt();
      final y = (cardOrigin + cardSize.height + CrimpyTheme.raisedOffset - 1)
          .toInt();
      final i = (y * width + x) * 4;
      return Color.fromARGB(
        data.getUint8(i + 3),
        data.getUint8(i),
        data.getUint8(i + 1),
        data.getUint8(i + 2),
      );
    }

    Widget cardOf({VoidCallback? onTap, bool? raised}) => CrimpyCard.simple(
      onTap: onTap,
      raised: raised,
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      child: SizedBox(height: cardSize.height),
    );

    testWidgets('under a tapped card', (tester) async {
      expect(
        await paintedInShadowBand(tester, cardOf(onTap: () {})),
        CrimpyTheme.outline,
      );
    });

    testWidgets('under a card raised without a tap', (tester) async {
      expect(
        await paintedInShadowBand(tester, cardOf(raised: true)),
        CrimpyTheme.outline,
      );
    });

    testWidgets('and not under a flat card', (tester) async {
      expect(
        await paintedInShadowBand(tester, cardOf()),
        CrimpyTheme.bgPrimary,
      );
    });
  });

  testWidgets('a tapped card ripples over its surface, not in its margin', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: CrimpyCard.simple(
              onTap: () => taps++,
              margin: const EdgeInsets.only(bottom: 40),
              child: const SizedBox(height: 20),
            ),
          ),
        ),
      ),
    );

    expect(
      find.ancestor(of: find.byType(Ink), matching: find.byType(InkWell)),
      findsOneWidget,
    );
    final card = tester.getRect(find.byType(CrimpyCard));
    await tester.tapAt(Offset(card.center.dx, card.bottom - 20));
    expect(taps, 0);
    await tester.tapAt(Offset(card.center.dx, card.top + 10));
    expect(taps, 1);
  });
}

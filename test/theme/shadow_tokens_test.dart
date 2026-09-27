import 'dart:io';

import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:flutter/material.dart';
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

  testWidgets('a card is raised when tapped as a whole, flat otherwise', (
    tester,
  ) async {
    BoxDecoration surfaceOf(Widget card) {
      final ink = find.descendant(
        of: find.byWidget(card),
        matching: find.byType(Ink),
      );
      if (ink.evaluate().isNotEmpty) {
        return tester.widget<Ink>(ink).decoration! as BoxDecoration;
      }
      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byWidget(card),
              matching: find.byType(Container),
            )
            .first,
      );
      return container.decoration! as BoxDecoration;
    }

    final tapped = CrimpyCard.simple(onTap: () {}, child: const Text('a'));
    final still = const CrimpyCard.simple(child: Text('b'));
    final chosen = const CrimpyCard.simple(raised: true, child: Text('c'));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: Column(children: [tapped, still, chosen])),
      ),
    );

    expect(surfaceOf(tapped).boxShadow, CrimpyTheme.raisedShadow);
    expect(surfaceOf(still).boxShadow, isNull);
    expect(surfaceOf(chosen).boxShadow, CrimpyTheme.raisedShadow);
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

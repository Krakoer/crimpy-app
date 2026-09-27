import 'dart:io';

import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A size, a tracking or a family named outside the theme. The app has one
/// type scale, the TYPE section of CrimpyTheme, and a widget takes a style from
/// it rather than stating a size of its own. A display number states its size
/// through CrimpyTheme.numerals, which is a call rather than a `fontSize:`, and
/// a screen scaling its type with its layout does it through
/// TextStyle.apply. Reading a slot of the Material textTheme is the same
/// escape by another door: those slots carry sizes the widget cannot see, and
/// a slot resized for Material's sake silently resizes every screen reading it.
/// See Krakoer/crimpy#172.
final RegExp typeName = RegExp(
  r'\b(fontSize|letterSpacing|fontFamily):|\bGoogleFonts\b|\btextTheme\.',
);

/// Heavier than any style of the scale. Heavy type everywhere was the problem
/// the scale was drawn to solve: a page title at w900 outweighed the content
/// under it.
final RegExp heavyWeight = RegExp(r'\bFontWeight\.(w800|w900)\b');

const String themeFile = 'lib/theme/crimpy_theme.dart';

bool isGenerated(String path) =>
    path.endsWith('.g.dart') || path.endsWith('.freezed.dart');

List<String> offencesOf(RegExp pattern, {bool skipTheme = true}) {
  final offences = <String>[];
  for (final entity in Directory('lib').listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    if (isGenerated(entity.path)) continue;
    if (skipTheme && entity.path == themeFile) continue;
    final lines = entity.readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      if (lines[i].trimLeft().startsWith('//')) continue;
      for (final match in pattern.allMatches(lines[i])) {
        offences.add('${entity.path}:${i + 1} names ${match.group(0)}');
      }
    }
  }
  return offences;
}

void main() {
  test('no file outside the theme names a size, a tracking, a family or a '
      'textTheme slot', () {
    final offences = offencesOf(typeName);
    expect(offences, isEmpty, reason: offences.join('\n'));
  });

  test('nothing is set heavier than w700', () {
    final offences = offencesOf(heavyWeight, skipTheme: false);
    expect(offences, isEmpty, reason: offences.join('\n'));
  });

  test('the scan recognises a size and ignores the theme styles', () {
    expect(typeName.hasMatch('TextStyle(fontSize: 12)'), isTrue);
    expect(typeName.hasMatch('.copyWith(letterSpacing: 2)'), isTrue);
    expect(typeName.hasMatch("fontFamily: 'JetBrainsMono',"), isTrue);
    expect(typeName.hasMatch('Theme.of(context).textTheme.bodySmall'), isTrue);
    expect(typeName.hasMatch('style: CrimpyTheme.body,'), isFalse);
    expect(typeName.hasMatch('CrimpyTheme.numerals(48)'), isFalse);
    expect(typeName.hasMatch('.apply(fontSizeFactor: scale)'), isFalse);
    expect(heavyWeight.hasMatch('fontWeight: FontWeight.w900,'), isTrue);
    expect(heavyWeight.hasMatch('fontWeight: FontWeight.w700,'), isFalse);
  });

  test('tracking tightens as the type grows', () {
    final scale = [
      CrimpyTheme.capsLabel,
      CrimpyTheme.labelSmall,
      CrimpyTheme.bodySmall,
      CrimpyTheme.body,
      CrimpyTheme.title,
      CrimpyTheme.titleLarge,
      CrimpyTheme.headline,
      CrimpyTheme.pageTitle,
    ];
    for (var i = 1; i < scale.length; i++) {
      expect(
        scale[i].letterSpacing!,
        lessThanOrEqualTo(scale[i - 1].letterSpacing!),
        reason: '${scale[i].fontSize}px is tracked wider than the size below',
      );
    }
    expect(CrimpyTheme.capsLabel.letterSpacing, greaterThan(0));
    expect(CrimpyTheme.pageTitle.letterSpacing, lessThan(0));
  });

  test('display numbers are tabular and tracked at -0.02 em', () {
    for (final size in [32.0, 76.0, 150.0]) {
      final style = CrimpyTheme.numerals(size);
      expect(style.fontFeatures, contains(const FontFeature.tabularFigures()));
      expect(style.letterSpacing, closeTo(size * -0.02, 1e-9));
    }
  });

  test('the theme names no family, so the platform sans renders', () {
    final theme = CrimpyTheme.lightTheme;
    expect(theme.appBarTheme.titleTextStyle!.fontFamily, isNull);
    expect(theme.textTheme.bodyMedium!.fontFamily, isNot('JetBrainsMono'));
  });
}

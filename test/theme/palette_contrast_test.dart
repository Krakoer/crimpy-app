import 'dart:math' as math;
import 'dart:ui';

import 'package:crimpy/models/common.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:flutter_test/flutter_test.dart';

/// The floor for text under the 18.66px bold threshold, which every label
/// checked here is: the smallest is a 10px bold override chip and the largest a
/// 14px bold button. Nothing in this file earns the 3:1 large text exemption.
const double contrastFloor = 4.5;

/// WCAG 2.1 relative luminance: each sRGB channel linearised, then weighted.
double _luminance(Color color) {
  double channel(double component) => component <= 0.03928
      ? component / 12.92
      : math.pow((component + 0.055) / 1.055, 2.4).toDouble();

  return 0.2126 * channel(color.r) +
      0.7152 * channel(color.g) +
      0.0722 * channel(color.b);
}

/// (L1 + 0.05) / (L2 + 0.05), the lighter of the two on top.
double contrastRatio(Color foreground, Color background) {
  final a = _luminance(foreground);
  final b = _luminance(background);
  return (math.max(a, b) + 0.05) / (math.min(a, b) + 0.05);
}

/// What an accent painted at [alpha] over [base] actually reads as. The app
/// tints a ground by lowering the accent's own alpha rather than by naming a
/// second colour, so the ground a label sits on has to be composited before it
/// can be measured.
Color tintOver(Color accent, double alpha, Color base) => Color.fromARGB(
  255,
  ((accent.r * alpha + base.r * (1 - alpha)) * 255).round(),
  ((accent.g * alpha + base.g * (1 - alpha)) * 255).round(),
  ((accent.b * alpha + base.b * (1 - alpha)) * 255).round(),
);

String _hex(Color color) =>
    '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';

void expectClearsFloor(String label, Color foreground, Color background) {
  final ratio = contrastRatio(foreground, background);
  expect(
    ratio,
    greaterThanOrEqualTo(contrastFloor),
    reason:
        '$label: ${_hex(foreground)} on ${_hex(background)} reads '
        '${ratio.toStringAsFixed(2)}:1, under the '
        '${contrastFloor.toStringAsFixed(1)}:1 floor',
  );
}

/// The hexes crimpy-frontend/src/routes/layout.css holds, token for token.
/// Neither repo can read the other, so each states the shared values and fails
/// when they are changed on one side alone.
const Map<String, (Color, String)> mirroredWebTokens = {
  '--pr-tx': (CrimpyTheme.accentOrangeText, '#965134'),
  '--gn-tx': (CrimpyTheme.accentGreenText, '#4e7154'),
  '--gd-tx': (CrimpyTheme.accentYellowText, '#8a6220'),
  '--pl-tx': (CrimpyTheme.accentPurpleText, '#735f7b'),
  '--rd-tx': (CrimpyTheme.statusErrorText, '#ac4747'),
  '--bl-tx': (CrimpyTheme.accentBlueText, '#4b698a'),
};

/// Every accent the app writes a label in on a tint of that same accent, with
/// the strongest tint any surface uses it at. A darker ground is the harder
/// case, so checking the strongest covers the lighter ones.
const List<(String, Color)> tintedAccents = [
  ('hangboard orange', CrimpyTheme.accentOrange),
  ('climbing gold', CrimpyTheme.accentYellow),
  ('stretching green', CrimpyTheme.accentGreen),
  ('workout purple', CrimpyTheme.accentPurple),
  ('other blue', CrimpyTheme.accentBlue),
  ('success green', CrimpyTheme.statusSuccess),
  ('error red', CrimpyTheme.statusError),
  ('warning gold', CrimpyTheme.statusWarning),
];

/// The strengths the widgets build their accent grounds at. [CrimpyTheme.tintAlpha]
/// is the strongest any of them may use, and the darker the ground the harder
/// the case, so checking it covers the lighter ones. The two below it are the
/// older grounds still in the tree.
const List<double> tintAlphas = [0.06, 0.1, CrimpyTheme.tintAlpha];

/// What the session cards of the history screens tint themselves at, under the
/// badges that tint again from the same accent.
///
/// This is a hand copy of the literal at rep_item_widget.dart and
/// sets_view_widget.dart, not a reference to it, and nothing makes it follow
/// them: raise theirs to 0.10 and this file keeps measuring 0.05 while the
/// stretching badge on that card drops to 4.36:1. It is kept here rather than
/// in CrimpyTheme because it is one screen's layering, not a palette rule, so
/// the cost of that copy is a line in this comment.
const double historyCardAlpha = 0.05;

void main() {
  group('accent text on a tint of its own accent', () {
    for (final (label, accent) in tintedAccents) {
      for (final alpha in tintAlphas) {
        test('$label holds the floor at alpha $alpha', () {
          final ground = tintOver(accent, alpha, CrimpyTheme.primaryWhite);
          expectClearsFloor(
            '$label at alpha $alpha',
            CrimpyTheme.textOn(accent),
            ground,
          );
        });
      }
    }

    test('every session activity holds the floor on its own tint', () {
      for (final activity in SessionActivity.values) {
        final accent = CrimpyTheme.activityColor(activity);
        expectClearsFloor(
          activity.name,
          CrimpyTheme.activityTextColor(activity),
          tintOver(accent, CrimpyTheme.tintAlpha, CrimpyTheme.primaryWhite),
        );
      }
    });

    // The history widgets nest one tint inside another: the rep badge of
    // rep_item_widget and the set chip of sets_view_widget are tinted at
    // [CrimpyTheme.tintAlpha] on a card already tinted at [historyCardAlpha]
    // from the same accent, so the ground they actually sit on is darker than
    // either alpha alone. Measured flat on white the pair looks safer than it
    // is, which is how a change to tintAlpha could pass this suite and still
    // put those badges under the floor.
    test('a tint nested in the history card still holds the floor', () {
      for (final activity in SessionActivity.values) {
        final accent = CrimpyTheme.activityColor(activity);
        final card = tintOver(
          accent,
          historyCardAlpha,
          CrimpyTheme.primaryWhite,
        );
        expectClearsFloor(
          '${activity.name} badge on the history card',
          CrimpyTheme.activityTextColor(activity),
          tintOver(accent, CrimpyTheme.tintAlpha, card),
        );
      }
    });

    // The four named status grounds are fixed hexes rather than alpha tints,
    // and are the app's own counterpart to the --*-lt tokens of the portal.
    test('the named status grounds hold the floor', () {
      expectClearsFloor(
        'statusError on bgError',
        CrimpyTheme.textOn(CrimpyTheme.statusError),
        CrimpyTheme.bgError,
      );
      expectClearsFloor(
        'statusWarning on bgWarning',
        CrimpyTheme.textOn(CrimpyTheme.statusWarning),
        CrimpyTheme.bgWarning,
      );
      expectClearsFloor(
        'statusSuccess on bgSuccess',
        CrimpyTheme.textOn(CrimpyTheme.statusSuccess),
        CrimpyTheme.bgSuccess,
      );
    });

    // The accents stay marks, so the text form has to be the darker of the two
    // or the token was moved the wrong way.
    test('every text form is darker than the accent it stands for', () {
      for (final (label, accent) in tintedAccents) {
        final ground = tintOver(
          accent,
          CrimpyTheme.tintAlpha,
          CrimpyTheme.primaryWhite,
        );
        expect(
          contrastRatio(CrimpyTheme.textOn(accent), ground),
          greaterThan(contrastRatio(accent, ground)),
          reason: '$label reads no better as text than as a mark',
        );
      }
    });

    // Teal has no counterpart in the portal's palette, so it deliberately has
    // no text token. Answering with the accent itself is what keeps a caller
    // from being handed another hue.
    test('an accent with no text form answers with itself', () {
      expect(
        CrimpyTheme.textOn(CrimpyTheme.accentTeal),
        CrimpyTheme.accentTeal,
      );
    });
  });

  group('parity with the web portal palette', () {
    for (final entry in mirroredWebTokens.entries) {
      test('${entry.key} still holds the value layout.css holds', () {
        final (color, hex) = entry.value;
        expect(
          _hex(color),
          hex,
          reason:
              '${entry.key} moved in crimpy-frontend/src/routes/layout.css '
              'without this theme moving with it, or the other way round',
        );
      });
    }

    test('protocolColor and goalColor are the shared text tokens', () {
      expect(CrimpyTheme.protocolColor, CrimpyTheme.accentYellowText);
      expect(CrimpyTheme.goalColor, CrimpyTheme.accentGreenText);
    });
  });
}

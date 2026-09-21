import 'dart:io';
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

/// The surface the history cards are drawn on. White rather than bgSecondary
/// since session_reps_card.dart moved its block card there, and stated here
/// because a nested tint composited over the wrong base reads better than it
/// paints: over bgSecondary the same stretching badge is 4.40:1, not 4.57:1.
const Color historyCardBase = CrimpyTheme.bgPrimary;

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

/// The floor an accent answers to when it is not small text: an icon, a rule,
/// or type at or above 18.66px bold, which WCAG 1.4.3 exempts from the 4.5:1
/// floor and 1.4.11 holds to the same 3:1 as any other non text content.
const double markFloor = 3.0;

/// Large text in WCAG terms, which is what lets a 32px figure keep its accent.
bool isLargeText(double sizePx, bool bold) =>
    sizePx >= 24 || (sizePx >= 18.66 && bold);

/// The neutral grounds this app paints an accent on: the white of a card, a
/// dialog and every Scaffold, plus the two greys a list row settles to.
const Map<String, Color> neutralGrounds = {
  'bgPrimary': CrimpyTheme.bgPrimary,
  'bgSecondary': CrimpyTheme.bgSecondary,
  'bgHover': CrimpyTheme.bgHover,
};

void expectClearsMarkFloor(String label, Color foreground, Color background) {
  final ratio = contrastRatio(foreground, background);
  expect(
    ratio,
    greaterThanOrEqualTo(markFloor),
    reason:
        '$label: ${_hex(foreground)} on ${_hex(background)} reads '
        '${ratio.toStringAsFixed(2)}:1, under the '
        '${markFloor.toStringAsFixed(1)}:1 mark floor',
  );
}

/// Where the sweep of Krakoer/crimpy#128 looks for an accent written on a
/// neutral ground. Generated Drift and Riverpod output paints nothing.
final Directory libRoot = Directory('lib');

const Set<String> generatedSuffixes = {'.g.dart', '.freezed.dart'};

/// The accent names a widget can write, with the value each one holds. Spelled
/// out rather than reflected, because a Flutter test has no mirrors; a name
/// missing from here is a pairing the scan cannot see rather than one it passes.
final Map<String, Color> scannedAccents = {
  'accentOrange': CrimpyTheme.accentOrange,
  'primaryOrange': CrimpyTheme.primaryOrange,
  'accentGreen': CrimpyTheme.accentGreen,
  'accentYellow': CrimpyTheme.accentYellow,
  'accentPurple': CrimpyTheme.accentPurple,
  'accentBlue': CrimpyTheme.accentBlue,
  'accentTeal': CrimpyTheme.accentTeal,
  'statusSuccess': CrimpyTheme.statusSuccess,
  'statusError': CrimpyTheme.statusError,
  'statusWarning': CrimpyTheme.statusWarning,
  'statusInfo': CrimpyTheme.statusInfo,
  'assessmentColor': CrimpyTheme.assessmentColor,
  'trainingColor': CrimpyTheme.trainingColor,
  'stretchingColor': CrimpyTheme.stretchingColor,
  'successColor': CrimpyTheme.successColor,
  'errorColor': CrimpyTheme.errorColor,
  'warningColor': CrimpyTheme.warningColor,
};

/// A colour already asked for through the theme's own helpers is this scan's
/// answer rather than its question, and one faded by an alpha is not the token
/// it names any more.
final RegExp resolvedByTheme = RegExp(
  r'textOn\(|markOn\(|tintOf\(|withValues\(|withOpacity\(',
);

final RegExp styleOpeners = RegExp(r'\b(TextStyle|Icon|FaIcon)\(');

/// The value of a `color:` argument, up to the comma that ends it. Spelled
/// across newlines and one level of nesting rather than to the end of the line,
/// because `dart format` wraps a long value onto its own line and a scan that
/// stops at the newline reads `CrimpyTheme.textOn(` as the whole answer.
final RegExp colourArgument = RegExp(
  r'\bcolor:\s*((?:[^,()]|\((?:[^()]|\([^()]*\))*\))*)',
);
final RegExp fontSizeArgument = RegExp(r'fontSize:\s*([^\n,]*)');
final RegExp numberLiteral = RegExp(r'\d+(?:\.\d+)?');
final RegExp boldWeight = RegExp(r'FontWeight\.(?:bold|w700|w800|w900)');

/// The text of the call that starts at [start], up to its matching bracket.
String? callBody(String source, int start) {
  var depth = 0;
  for (var i = source.indexOf('(', start); i >= 0 && i < source.length; i++) {
    if (source[i] == '(') depth++;
    if (source[i] == ')') {
      depth--;
      if (depth == 0) return source.substring(start, i + 1);
    }
  }
  return null;
}

class NeutralOffence {
  final String file;
  final int line;
  final String kind;
  final String accent;
  final double ratio;
  final double floor;

  NeutralOffence(
    this.file,
    this.line,
    this.kind,
    this.accent,
    this.ratio,
    this.floor,
  );

  @override
  String toString() =>
      '$file:$line writes $accent as $kind on bgPrimary, '
      '${ratio.toStringAsFixed(2)}:1 against a '
      '${floor.toStringAsFixed(1)}:1 floor';
}

/// Every accent written into a `TextStyle`, an `Icon` or a `FaIcon` without
/// going through the theme's helpers, measured against white.
///
/// The ground is taken to be white rather than looked up. A Flutter ground is a
/// decoration on some ancestor Container and cannot be read from the call site,
/// and every tint in this app is lighter than no tint at all, so assuming white
/// never overstates a defect: a pairing this reports reads at least as badly as
/// it says. An accent written on its own tint already goes through
/// [CrimpyTheme.textOn] and is skipped because of it.
///
/// What it cannot see, stated so its silence is not read as proof: a colour
/// held in a variable or taken from a parameter, which is most of the session
/// history; a style built by a helper, the way full_tank_layout builds one; and
/// a size computed at build time, which is held to the mark floor alone since
/// the scan has no number to judge it by.
List<NeutralOffence> neutralOffences() {
  final offences = <NeutralOffence>[];
  for (final entity in libRoot.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    if (generatedSuffixes.any(entity.path.endsWith)) continue;
    final source = entity.readAsStringSync();
    for (final opener in styleOpeners.allMatches(source)) {
      final body = callBody(source, opener.start);
      if (body == null) continue;
      final colour = colourArgument.firstMatch(body);
      if (colour == null) continue;
      final value = colour.group(1)!;
      if (resolvedByTheme.hasMatch(value)) continue;
      final named = scannedAccents.keys.where(
        (name) => RegExp('\\b$name\\b').hasMatch(value),
      );
      if (named.isEmpty) continue;

      final isText = opener.group(1) == 'TextStyle';
      final size = fontSizeArgument.firstMatch(body);
      final written = size == null
          ? const <double>[]
          : numberLiteral
                .allMatches(size.group(1)!)
                .map((match) => double.parse(match.group(0)!))
                .toList();
      final smallest = written.isEmpty
          ? null
          : written.reduce((a, b) => a < b ? a : b);
      final small =
          isText &&
          smallest != null &&
          !isLargeText(smallest, boldWeight.hasMatch(body));
      final floor = small ? contrastFloor : markFloor;
      final line =
          '\n'.allMatches(source.substring(0, opener.start)).length + 1;
      for (final name in named) {
        final ratio = contrastRatio(
          scannedAccents[name]!,
          CrimpyTheme.bgPrimary,
        );
        if (ratio >= floor) continue;
        offences.add(
          NeutralOffence(
            entity.path,
            line,
            isText ? (small ? 'text' : 'large or unsized text') : 'mark',
            name,
            ratio,
            floor,
          ),
        );
      }
    }
  }
  offences.sort((a, b) => a.toString().compareTo(b.toString()));
  return offences;
}

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
        final card = tintOver(accent, historyCardAlpha, historyCardBase);
        expectClearsFloor(
          '${activity.name} badge on the history card',
          CrimpyTheme.activityTextColor(activity),
          tintOver(accent, CrimpyTheme.tintAlpha, card),
        );
      }
    });

    // Three named status grounds, fixed hexes rather than alpha tints, the
    // app's own counterpart to the --*-lt tokens of the portal. bgInfo is the
    // fourth and is deliberately absent: its accent is teal, which has no text
    // token because the portal palette has no teal to mirror, so textOn answers
    // with the accent itself and the pair reads 3.50:1. Nothing writes text on
    // bgInfo today; if anything ever does, teal needs a text form first.
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

  group('accent on a neutral ground', () {
    // The text form is what a label takes on white, which is the sweep of
    // Krakoer/crimpy#128. Measured on all three neutrals, since a list row
    // settles to bgHover under a finger and that is the darkest of them.
    for (final (label, accent) in tintedAccents) {
      for (final entry in neutralGrounds.entries) {
        test('$label reads as text on ${entry.key}', () {
          expectClearsFloor(
            '$label text on ${entry.key}',
            CrimpyTheme.textOn(accent),
            entry.value,
          );
        });
      }
    }

    // The accents are the marks, and all but gold clear the mark floor on
    // white. That is the whole of why the sweep is not uniform: an icon keeps
    // its accent where a 10px label beside it cannot.
    test('gold is the only accent under the mark floor on white', () {
      final failing = [
        for (final (label, accent) in tintedAccents)
          if (contrastRatio(accent, CrimpyTheme.bgPrimary) < markFloor) label,
      ];
      expect(failing, ['climbing gold', 'warning gold']);
    });

    test('markOn moves an accent exactly when the accent fails', () {
      for (final (label, accent) in tintedAccents) {
        final clears =
            contrastRatio(accent, CrimpyTheme.bgPrimary) >= markFloor;
        expect(
          CrimpyTheme.markOn(accent),
          clears ? accent : CrimpyTheme.textOn(accent),
          reason: clears
              ? '$label was moved off its accent although the accent clears '
                    'the mark floor'
              : '$label was left on an accent that misses the mark floor',
        );
        expectClearsMarkFloor(
          '$label mark',
          CrimpyTheme.markOn(accent),
          CrimpyTheme.bgPrimary,
        );
      }
    });

    test('an accent with no mark form answers with itself', () {
      expect(
        CrimpyTheme.markOn(CrimpyTheme.accentTeal),
        CrimpyTheme.accentTeal,
      );
    });

    // The session labels of the program rows and the home card, which read
    // 2.25:1 in bare gold before Krakoer/crimpy#119 swept them.
    test('every session activity label holds the floor on a white card', () {
      for (final activity in SessionActivity.values) {
        expectClearsFloor(
          '${activity.name} label',
          CrimpyTheme.activityTextColor(activity),
          CrimpyTheme.bgPrimary,
        );
      }
    });

    test('every session activity mark holds its floor on a white card', () {
      for (final activity in SessionActivity.values) {
        expectClearsMarkFloor(
          '${activity.name} mark',
          CrimpyTheme.markOn(CrimpyTheme.activityColor(activity)),
          CrimpyTheme.bgPrimary,
        );
      }
    });
  });

  group('surfaces that write an accent on a neutral ground', () {
    // Checked against shapes it has to read, so an empty offence list is
    // evidence of something rather than of a scan that reads nothing.
    test('reads a call body up to its own closing bracket', () {
      const source = 'Icon(Icons.x, color: CrimpyTheme.accentYellow, size: 24)';
      expect(callBody(source, 0), source);
      expect(
        callBody('Icon(Icons.x, color: red)  rest', 0),
        'Icon(Icons.x, color: red)',
      );
    });

    test('separates the two floors', () {
      expect(isLargeText(32, true), isTrue);
      expect(isLargeText(20, true), isTrue);
      expect(isLargeText(18, true), isFalse);
      expect(isLargeText(24, false), isTrue);
      expect(isLargeText(20, false), isFalse);
    });

    test('finds no accent under its floor on a neutral ground', () {
      final offences = neutralOffences();
      expect(
        offences.map((offence) => offence.toString()).toList(),
        isEmpty,
        reason:
            'an accent under its floor on a neutral ground:\n'
            '${offences.join('\n')}',
      );
    });
  });
}

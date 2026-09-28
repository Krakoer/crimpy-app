import 'dart:io';

import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:flutter_test/flutter_test.dart';

/// A padding, a margin or a gap named as a number outside the theme. The app
/// has one spacing scale, the SPACING section of CrimpyTheme, and a widget
/// takes a step off it rather than a number of its own, so two things that do
/// the same job are as roomy as each other. See Krakoer/crimpy#169 and
/// Krakoer/crimpy#174.
///
/// Scanned: every argument of an `EdgeInsets` or `EdgeInsetsDirectional`
/// constructor, the `height:` and `width:` of a `SizedBox`, and the
/// `spacing:` family of Row, Column, Wrap and grids. Zero is not a size.

const String themeFile = 'lib/theme/crimpy_theme.dart';

/// Sizes that are not a step of the scale on purpose. Each entry names the
/// file and the numbers it may use there, with the reason. Keep it small: a
/// number that is only spacing belongs on the scale, and an entry nothing
/// matches any more fails the test so it cannot linger.
const Map<String, Map<String, String>> offScale = {
  // The run screen sizes everything off its own height through `_s` and
  // `scale`, so its gaps are proportions tuned to fit one screen, not steps.
  'lib/views/screens/trainings/play_training_screen/layouts/full_tank_layout.dart':
      {
        '2': 'run screen proportions',
        '3': 'run screen proportions',
        '4': 'run screen proportions',
        '6': 'run screen proportions',
        '8': 'run screen proportions',
        '10': 'run screen proportions',
        '12': 'run screen proportions',
        '14': 'run screen proportions',
        '16': 'run screen proportions',
        '18': 'run screen proportions',
        '20': 'run screen proportions',
        '28': 'run screen proportions',
      },
  'lib/views/screens/assessments/mvc_run_screen.dart': {
    '0.75': 'the gauge target line sits at a fraction of the bar height',
    '2': 'the gauge target line is 2dp thick',
  },
  'lib/views/screens/home_screen/history/widgets/week_histogram_widget.dart': {
    '66': 'chart geometry: the room under the bars for the labels',
    '6': 'chart geometry: counted in the 66 above',
    '24': 'chart geometry: bar width',
  },
  'lib/views/screens/home_screen/history/week_histogram_card.dart': {
    '66': 'chart geometry: the same room under the bars, held while loading',
  },
  'lib/views/screens/trainings/programs/program_detail_screen.dart': {
    '2': 'calendar geometry: the gutter between day cells',
    '36': 'the calendar week label column, a width not a gap',
    '40': 'empty state: whitespace around the not-planned message',
  },
  'lib/views/screens/home_screen/favorite_training.dart': {
    '200': 'the favorite card height',
    '300': 'the empty state illustration box',
  },
  'lib/views/screens/profile_screen/widgets/bodyweight_card.dart': {
    '24': 'icon box of the loading indicator',
  },
  'lib/views/screens/availability/week_availability_screen.dart': {
    '14': 'icon box of the saving indicator',
  },
  'lib/views/screens/auth/email_verification_screen.dart': {
    '16': 'icon box of the button spinner',
  },
  'lib/views/screens/auth/forgot_password_screen.dart': {
    '20': 'icon box of the button spinner',
  },
  'lib/views/screens/auth/login_screen.dart': {
    '20': 'icon box of the button spinner',
    '48': 'whitespace between the brand block and the form',
  },
  'lib/views/screens/auth/registration_screen.dart': {
    '20': 'icon box of the button spinner',
    '48': 'whitespace between the brand block and the form',
  },
  'lib/views/screens/settings_screen/widgets/reset_password_tile.dart': {
    '20': 'icon box of the tile spinner',
  },
  'lib/views/screens/trainings/trainings_list_screen/trainings_list_screen.dart':
      {'80.0': 'room under the list so the FAB does not cover the last row'},
  'lib/views/screens/trainings/post_workout_screen.dart': {
    '100': 'whitespace above the result headline',
  },
  'lib/views/screens/assessments/post_assessment_screen.dart': {
    '100': 'whitespace above the result headline',
  },
};

final RegExp numberLiteral = RegExp(r'(?<![\w.])\d+(\.\d+)?(?![\w.])');

final RegExp spacingCall = RegExp(
  r'\bEdgeInsets(Directional|Geometry)?\.\w+\(',
);
final RegExp sizedBoxCall = RegExp(r'\bSizedBox\(');
final RegExp spacingArgument = RegExp(
  r'\b(spacing|runSpacing|mainAxisSpacing|crossAxisSpacing):',
);
final RegExp sizeArgument = RegExp(r'^\s*(height|width):');

/// The source with comments and string literals blanked out, same length, so
/// an offset still maps to its line.
String blanked(String source) => source
    .replaceAllMapped(RegExp(r'//[^\n]*'), (m) => ' ' * m.group(0)!.length)
    .replaceAllMapped(
      RegExp(
        r"'[^'\n]*'|"
        r'"[^"\n]*"',
      ),
      (m) => ' ' * m.group(0)!.length,
    );

/// The offset of the bracket that closes the one at [open].
int closing(String source, int open) {
  var depth = 0;
  for (var i = open; i < source.length; i++) {
    final c = source[i];
    if (c == '(' || c == '[' || c == '{') depth++;
    if (c == ')' || c == ']' || c == '}') {
      depth--;
      if (depth == 0) return i;
    }
  }
  return source.length;
}

/// Where each top-level argument of the call spanning [start]..[end] begins
/// and ends.
List<(int, int)> argumentsOf(String source, int start, int end) {
  final spans = <(int, int)>[];
  var depth = 0;
  var from = start;
  for (var i = start; i < end; i++) {
    final c = source[i];
    if (c == '(' || c == '[' || c == '{') depth++;
    if (c == ')' || c == ']' || c == '}') depth--;
    if (c == ',' && depth == 0) {
      spans.add((from, i));
      from = i + 1;
    }
  }
  spans.add((from, end));
  return spans;
}

/// Every spacing number in [source]: the literal and the offset it sits at.
List<(String, int)> spacingNumbers(String source) {
  final text = blanked(source);
  final spans = <(int, int)>[];
  for (final call in spacingCall.allMatches(text)) {
    spans.add((call.end, closing(text, call.end - 1)));
  }
  for (final call in sizedBoxCall.allMatches(text)) {
    final end = closing(text, call.end - 1);
    for (final (from, to) in argumentsOf(text, call.end, end)) {
      final name = sizeArgument.firstMatch(text.substring(from, to));
      if (name != null) spans.add((from + name.end, to));
    }
  }
  for (final argument in spacingArgument.allMatches(text)) {
    var depth = 0;
    var i = argument.end;
    for (; i < text.length; i++) {
      final c = text[i];
      if (depth == 0 && (c == ',' || c == ')' || c == ']' || c == '}')) {
        break;
      }
      if (c == '(' || c == '[' || c == '{') depth++;
      if (c == ')' || c == ']' || c == '}') depth--;
    }
    spans.add((argument.end, i));
  }
  final found = <(String, int)>[];
  for (final (from, to) in spans) {
    for (final number in numberLiteral.allMatches(text.substring(from, to))) {
      if (double.parse(number.group(0)!) == 0) continue;
      final start = from + number.start;
      final end = from + number.end;
      if (isComparedAt(text, start, end)) continue;
      found.add((number.group(0)!, start));
    }
  }
  return found;
}

/// A number compared against, such as the `6` of `d == 6 ? 0 : gap`, counts
/// something rather than spacing it, and a token in its place would compare
/// an index with a size.
final RegExp comparisonBefore = RegExp(r'(==|!=|<=|>=|(?<!=)>|<|%)\s*$');
final RegExp comparisonAfter = RegExp(r'^\s*(==|!=|<=|>=|<|>|%)');

bool isComparedAt(String text, int start, int end) =>
    comparisonBefore.hasMatch(text.substring(0, start)) ||
    comparisonAfter.hasMatch(text.substring(end));

bool isGenerated(String path) =>
    path.endsWith('.g.dart') || path.endsWith('.freezed.dart');

void main() {
  test(
    'no file outside the theme names a spacing number off the allow-list',
    () {
      final offences = <String>[];
      final used = <String>{};
      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        if (isGenerated(entity.path) || entity.path == themeFile) continue;
        final source = entity.readAsStringSync();
        final allowed = offScale[entity.path] ?? const {};
        for (final (number, offset) in spacingNumbers(source)) {
          if (allowed.containsKey(number)) {
            used.add('${entity.path} $number');
            continue;
          }
          final line = '\n'.allMatches(source.substring(0, offset)).length + 1;
          offences.add('${entity.path}:$line names $number');
        }
      }
      expect(offences, isEmpty, reason: offences.join('\n'));

      final stale = [
        for (final MapEntry(key: path, value: numbers) in offScale.entries)
          for (final number in numbers.keys)
            if (!used.contains('$path $number')) '$path $number',
      ];
      expect(
        stale,
        isEmpty,
        reason: 'allowed but unused:\n${stale.join('\n')}',
      );
    },
  );

  test('the scan finds a spacing number and ignores a token', () {
    List<String> numbersIn(String source) => [
      for (final (number, _) in spacingNumbers(source)) number,
    ];

    expect(numbersIn('padding: EdgeInsets.all(16),'), ['16']);
    expect(numbersIn('EdgeInsets.only(\n  left: 12.0,\n  bottom: 80,\n)'), [
      '12.0',
      '80',
    ]);
    expect(numbersIn('EdgeInsetsDirectional.only(start: 6)'), ['6']);
    expect(numbersIn('EdgeInsetsGeometry.symmetric(vertical: 20)'), ['20']);
    expect(numbersIn('const SizedBox(height: 8)'), ['8']);
    expect(numbersIn('SizedBox(width: 20, height: 20, child: x)'), [
      '20',
      '20',
    ]);
    expect(numbersIn('Wrap(spacing: 6, runSpacing: 4, children: [])'), [
      '6',
      '4',
    ]);
    expect(numbersIn('EdgeInsets.all(CrimpyTheme.spaceLg)'), isEmpty);
    expect(numbersIn('const SizedBox(height: CrimpyTheme.spaceSm)'), isEmpty);
    expect(numbersIn('EdgeInsets.only(right: last ? 0 : gap)'), isEmpty);
    expect(numbersIn('EdgeInsets.zero'), isEmpty);
    expect(numbersIn('EdgeInsets.only(right: d == 6 ? 0 : 4)'), ['4']);
    expect(numbersIn('EdgeInsets.only(left: i < 2 ? 8 : 0)'), ['8']);
    expect(numbersIn('EdgeInsets.only(left: 3 != i ? 8 : 0)'), ['8']);
    expect(numbersIn('SizedBox(height: switch (d) { A => 8, _ => 4 })'), [
      '8',
      '4',
    ]);
    expect(numbersIn('EdgeInsets.all(foo<double>(8))'), ['8']);
    expect(numbersIn('SizedBox(child: Text("16"))'), isEmpty);
    expect(numbersIn('// EdgeInsets.all(16)'), isEmpty);
    expect(numbersIn('SizedBox.shrink()'), isEmpty);
    expect(numbersIn('Container(height: 8)'), isEmpty);
  });

  test('the scale climbs in steps', () {
    const scale = [
      CrimpyTheme.spaceXs,
      CrimpyTheme.spaceSm,
      CrimpyTheme.spaceMd,
      CrimpyTheme.spaceLg,
      CrimpyTheme.spaceLgPlus,
      CrimpyTheme.spaceXl,
      CrimpyTheme.spaceXxl,
    ];
    for (var i = 1; i < scale.length; i++) {
      expect(scale[i], greaterThan(scale[i - 1]));
    }
  });
}

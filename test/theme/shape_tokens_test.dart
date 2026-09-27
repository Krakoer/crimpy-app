import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// A corner, or a border that carries one, named outside the theme. The app
/// has one corner, CrimpyTheme.corner, and a widget that wants it takes
/// CrimpyTheme.corners, CrimpyTheme.shape or CrimpyTheme.framed. A field takes
/// its border from the theme's inputDecorationTheme and names none. A circle
/// is a shape rather than a corner and is not matched. See Krakoer/crimpy#171.
final RegExp cornerName = RegExp(
  r'\b(BorderRadius(Directional)?\.(circular|only|vertical|horizontal|all|zero)'
  r'|Radius\.(circular|elliptical|zero)'
  r'|RoundedRectangleBorder|RoundedSuperellipseBorder|StadiumBorder'
  r'|BeveledRectangleBorder'
  r'|ContinuousRectangleBorder|OutlineInputBorder|UnderlineInputBorder)\b',
);

const String themeFile = 'lib/theme/crimpy_theme.dart';

final RegExp dropdownOpening = RegExp(
  r'\bDropdownButton(FormField)?(<[^>(]*>)?\(',
);

/// The index just past the parenthesis that closes a call whose arguments
/// start at [start].
int callEnd(String source, int start) {
  var depth = 1;
  for (var i = start; i < source.length; i++) {
    if (source[i] == '(') depth++;
    if (source[i] == ')' && --depth == 0) return i;
  }
  return source.length;
}

void main() {
  test('no file outside the theme names a corner', () {
    final offences = <String>[];
    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      if (entity.path == themeFile) continue;
      final lines = entity.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (lines[i].trimLeft().startsWith('//')) continue;
        for (final match in cornerName.allMatches(lines[i])) {
          offences.add('${entity.path}:${i + 1} names ${match.group(0)}');
        }
      }
    }
    expect(offences, isEmpty, reason: offences.join('\n'));
  });

  // Material draws a dropdown's open menu at a 2px radius of its own unless
  // the widget names one, and no theme reaches it, so the corner guard above
  // cannot see a dropdown that forgot.
  test('every dropdown names the theme corner for its menu', () {
    final offences = <String>[];
    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final source = entity.readAsStringSync();
      for (final match in dropdownOpening.allMatches(source)) {
        final call = source.substring(match.end, callEnd(source, match.end));
        if (!call.contains('borderRadius: CrimpyTheme.corners')) {
          final line = '\n'.allMatches(source.substring(0, match.start)).length;
          offences.add('${entity.path}:${line + 1} opens a rounded menu');
        }
      }
    }
    expect(offences, isEmpty, reason: offences.join('\n'));
  });

  test('the scan recognises a corner and ignores the theme tokens', () {
    expect(cornerName.hasMatch('BorderRadius.circular(8)'), isTrue);
    expect(cornerName.hasMatch('radius: Radius.circular(16),'), isTrue);
    expect(cornerName.hasMatch('border: OutlineInputBorder(),'), isTrue);
    expect(cornerName.hasMatch('shape: RoundedRectangleBorder('), isTrue);
    expect(cornerName.hasMatch('BorderRadiusDirectional.circular(8)'), isTrue);
    expect(cornerName.hasMatch('borderRadius: CrimpyTheme.corners,'), isFalse);
    expect(cornerName.hasMatch('shape: CrimpyTheme.shape,'), isFalse);
    expect(cornerName.hasMatch('shape: BoxShape.circle,'), isFalse);
  });
}

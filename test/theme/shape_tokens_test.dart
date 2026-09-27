import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// A corner, or a border that carries one, named outside the theme. The app
/// has one corner, CrimpyTheme.corner, and a widget that wants it takes
/// CrimpyTheme.corners, CrimpyTheme.shape or CrimpyTheme.framed. A field takes
/// its border from the theme's inputDecorationTheme and names none. A circle
/// is a shape rather than a corner and is not matched. See Krakoer/crimpy#171.
final RegExp cornerName = RegExp(
  r'\b(BorderRadius\.(circular|only|vertical|horizontal|all|zero)'
  r'|Radius\.(circular|elliptical|zero)'
  r'|RoundedRectangleBorder|StadiumBorder|BeveledRectangleBorder'
  r'|ContinuousRectangleBorder|OutlineInputBorder|UnderlineInputBorder)\b',
);

const String themeFile = 'lib/theme/crimpy_theme.dart';

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

  test('the scan recognises a corner and ignores the theme tokens', () {
    expect(cornerName.hasMatch('BorderRadius.circular(8)'), isTrue);
    expect(cornerName.hasMatch('radius: Radius.circular(16),'), isTrue);
    expect(cornerName.hasMatch('border: OutlineInputBorder(),'), isTrue);
    expect(cornerName.hasMatch('shape: RoundedRectangleBorder('), isTrue);
    expect(cornerName.hasMatch('borderRadius: CrimpyTheme.corners,'), isFalse);
    expect(cornerName.hasMatch('shape: CrimpyTheme.shape,'), isFalse);
    expect(cornerName.hasMatch('shape: BoxShape.circle,'), isFalse);
  });
}

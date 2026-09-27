import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The palette itself, which only lib/theme/crimpy_theme.dart may name. A
/// widget names the role a colour plays there, so that one meaning can change
/// without every other meaning painted in the same hue moving with it. See
/// Krakoer/crimpy#168.
final RegExp paletteName = RegExp(
  r'CrimpyTheme\.(primaryOrange|primaryBlack|primaryWhite|accent[A-Z]\w*)\b',
);

const String paletteFile = 'lib/theme/crimpy_theme.dart';

void main() {
  test('no file outside the theme names a palette hue', () {
    final offences = <String>[];
    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      if (entity.path == paletteFile) continue;
      final lines = entity.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        for (final match in paletteName.allMatches(lines[i])) {
          offences.add('${entity.path}:${i + 1} names ${match.group(0)}');
        }
      }
    }
    expect(offences, isEmpty, reason: offences.join('\n'));
  });

  test('the scan recognises a palette name and ignores a role', () {
    expect(
      paletteName.hasMatch('color: CrimpyTheme.accentYellowText,'),
      isTrue,
    );
    expect(paletteName.hasMatch('color: CrimpyTheme.primaryOrange,'), isTrue);
    expect(paletteName.hasMatch('color: CrimpyTheme.action,'), isFalse);
    expect(paletteName.hasMatch('color: CrimpyTheme.textPrimary,'), isFalse);
  });
}

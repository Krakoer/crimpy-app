import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

/// Runs the rule over a throwaway package and asserts it flags exactly the
/// reads that drop the value the state is holding.
///
/// custom_lint has no in-process harness worth the coupling, so the rule is
/// exercised the way it runs for real: as a plugin, over a package on disk. The
/// package is written to a temp directory rather than kept in the repo, because
/// custom_lint has no exclusions and would otherwise report the deliberate
/// mistakes in it every time anyone lints the app.
///
/// `fixture_source.dart.txt` marks each line it expects to be flagged with
/// `// LINT`, so adding a case to it is all it takes to cover one.
void main() {
  test(
    'flags the reads that drop a held value, and only those',
    () async {
      final source = File('test/fixture_source.dart.txt').readAsStringSync();
      final expected = <int>[
        for (final (index, line) in source.split('\n').indexed)
          if (line.contains('// LINT')) index + 1,
      ];
      expect(expected, hasLength(23), reason: 'the fixture lost its markers');

      final rule = Directory.current.absolute.path;
      // The version the app is locked to, so the rule is proved against the
      // AsyncValue that ships rather than whatever pub.dev published last. The
      // cost is that a release relocating AsyncValue stops announcing itself
      // here; `flutter pub upgrade` is where that should be found anyway.
      final riverpod = _lockedVersion('riverpod');
      final dir = Directory.systemTemp.createTempSync('crimpy_lints_');
      addTearDown(() => dir.deleteSync(recursive: true));

      Directory(p.join(dir.path, 'lib')).createSync();
      File(p.join(dir.path, 'lib', 'fixture.dart')).writeAsStringSync(source);
      File(
        p.join(dir.path, 'analysis_options.yaml'),
      ).writeAsStringSync('analyzer:\n  plugins:\n    - custom_lint\n');
      File(p.join(dir.path, 'pubspec.yaml')).writeAsStringSync('''
name: fixture
publish_to: none

environment:
  sdk: '>=3.11.0 <4.0.0'

dependencies:
  riverpod: $riverpod

dev_dependencies:
  crimpy_lints:
    path: $rule
  custom_lint:
''');

      final pubGet = await Process.run('dart', [
        'pub',
        'get',
      ], workingDirectory: dir.path);
      expect(pubGet.exitCode, 0, reason: pubGet.stderr.toString());

      final run = await Process.run('dart', [
        'run',
        'custom_lint',
      ], workingDirectory: dir.path);
      final output = '${run.stdout}${run.stderr}';

      final flagged = RegExp(
        r'fixture\.dart:(\d+):\d+ .* keep_the_held_value',
      ).allMatches(output).map((m) => int.parse(m.group(1)!)).toList()..sort();

      expect(flagged, expected, reason: output);
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );
}

/// The version `pubspec.lock` pins a package to, read from the app above.
String _lockedVersion(String package) {
  final lines = File('../../pubspec.lock').readAsLinesSync();
  final start = lines.indexWhere((l) => l.trimRight() == '  $package:');
  if (start < 0) throw StateError('$package is not in the app lockfile');
  final version = lines
      .skip(start)
      .take(10)
      .firstWhere((l) => l.trimLeft().startsWith('version:'));
  return version.split('"')[1];
}

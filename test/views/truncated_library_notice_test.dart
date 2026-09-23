import 'dart:async';

import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:crimpy/views/widgets/truncated_library_notice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// The notice under an override of the one provider it reads, so each of the
/// three states it promises to handle can be driven directly.
Future<void> _pump(
  WidgetTester tester,
  Future<bool> Function(Ref ref) truncated,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [trainingLibraryTruncatedProvider.overrideWith(truncated)],
      child: const MaterialApp(home: Scaffold(body: TruncatedLibraryNotice())),
    ),
  );
  await tester.pump();
}

/// Matches the notice by the one thing about it that is not styling.
Finder get _notice => find.textContaining('start of your library');

void main() {
  group('the truncated library notice', () {
    testWidgets('says nothing about a whole library', (tester) async {
      await _pump(tester, (ref) async => false);

      expect(_notice, findsNothing);
    });

    testWidgets('says the library was cut short', (tester) async {
      await _pump(tester, (ref) async => true);

      expect(_notice, findsOneWidget);
    });

    testWidgets('stays hidden while the library is still loading', (
      tester,
    ) async {
      await _pump(tester, (ref) => Completer<bool>().future);

      // A pull to refresh puts the provider back into loading with the previous
      // value still in hand. A notice that rendered on anything but a resolved
      // true would flash on every pull, which is the failure this pins.
      expect(_notice, findsNothing);
    });

    testWidgets('stays hidden when the library read failed', (tester) async {
      await _pump(tester, (ref) async => throw Exception('offline'));

      // The screen around it already reports the failure. A banner here would
      // be a second report of it, and one that says something untrue: nothing
      // was cut, nothing was read.
      expect(_notice, findsNothing);
    });
  });
}

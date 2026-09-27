import 'package:crimpy/models/training.dart';
import 'package:crimpy/models/training_list_item.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:crimpy/views/screens/home_screen/favorite_training.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

List<TrainingListItem> _library(int count) => [
  for (var index = 0; index < count; index++)
    TrainingListItem.regular(
      Training(id: 't-$index', title: 'Training $index', items: const []),
    ),
];

/// The dialog on a given surface and text scale.
///
/// The size and the scale are both arguments because the defect this file
/// guards against only appears when the dialog's height budget is tight: the
/// notice sits in `AlertDialog.title`, which is inflexible, so it competes with
/// the content for room on a short screen or at a large text scale and nowhere
/// else.
Future<void> _pumpDialog(
  WidgetTester tester, {
  required bool truncated,
  Size surface = const Size(360, 800),
  double textScale = 1.0,
}) async {
  tester.view.physicalSize = surface;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        allTrainingsProvider.overrideWith((ref) async => _library(30)),
        trainingLibraryTruncatedProvider.overrideWith((ref) async => truncated),
      ],
      child: MaterialApp(
        // The surface's own size is kept: the list takes its height from it.
        home: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: const Scaffold(body: Center(child: PinTrainingDialog())),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// The dialog as the home screen opens it, through showDialog, where the
/// AlertDialog measures its content's intrinsic size.
Future<void> _pumpThroughShowDialog(
  WidgetTester tester, {
  required bool truncated,
  double textScale = 1.0,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        allTrainingsProvider.overrideWith((ref) async => _library(30)),
        trainingLibraryTruncatedProvider.overrideWith((ref) async => truncated),
      ],
      child: MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => const PinTrainingDialog(),
              ),
              child: const Text('Pin a training'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Pin a training'));
  await tester.pumpAndSettle();
}

/// The list's own height. It is fixed at 300, so this only tells whether the
/// notice took room from the list's box; whether the athlete can see it is
/// measured through the dialog's scroll view below.
double _listViewport(WidgetTester tester) =>
    tester.getSize(find.byType(ListView).first).height;

void main() {
  group('the pin training dialog', () {
    // The notice used to sit inside the dialog's fixed 300dp content box, above
    // an Expanded list. On a 360dp phone it wrapped to six lines and left the
    // list a 54dp window onto a two hundred entry library, which is less than
    // one row. The athlete past the ceiling is the only one who ever sees the
    // notice, so that took the screen away from exactly the person it is for.
    testWidgets('keeps the list its full height when the library was cut', (
      tester,
    ) async {
      await _pumpDialog(tester, truncated: true);

      expect(find.textContaining('start of your library'), findsOneWidget);
      expect(
        _listViewport(tester),
        300.0,
        reason: 'the notice must not take height from the training list',
      );
    });

    // The home screen opens this through showDialog, where the scrollable
    // AlertDialog measures its content's intrinsic width. A lazy ListView has
    // none to give, so the layout threw and the athlete saw an empty box.
    // Pumped in a Scaffold, as the tests above are, nothing asks for it.
    testWidgets('lists the trainings when opened as a dialog', (tester) async {
      await _pumpThroughShowDialog(tester, truncated: false);

      expect(tester.takeException(), isNull);
      expect(find.text('Training 0'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
    });

    testWidgets('is unchanged when the library is whole', (tester) async {
      await _pumpDialog(tester, truncated: false);

      expect(find.textContaining('start of your library'), findsNothing);
      expect(_listViewport(tester), 300.0);
    });

    // A small screen at an accessibility text scale is where the title and the
    // list cannot both fit. The dialog scrolls the two together, so the list
    // keeps its height and is reached by scrolling. Opened through showDialog,
    // as the home screen does, and measured by what actually shows inside the
    // dialog's scroll view once scrolled, not by the list's own size: that
    // size is fixed and would pass whether the athlete could see it or not.
    testWidgets(
      'brings the list into view on a small screen at a large text scale',
      (tester) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await _pumpThroughShowDialog(tester, truncated: true, textScale: 2.0);

        expect(tester.takeException(), isNull);

        final dialogScroll = find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(SingleChildScrollView),
        );
        await tester.drag(dialogScroll.first, const Offset(0, -600));
        await tester.pumpAndSettle();

        final viewport = tester.getRect(dialogScroll.first);
        final list = tester.getRect(find.byType(ListView).first);
        expect(
          viewport.intersect(list).height,
          greaterThan(48.0),
          reason: 'scrolling the dialog must show at least a row of the list',
        );
      },
    );
  });
}

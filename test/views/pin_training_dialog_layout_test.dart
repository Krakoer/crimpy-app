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
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: const Scaffold(body: Center(child: PinTrainingDialog())),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// The height the athlete can actually see the list through.
///
/// Measured off the `ListView` itself, which is the scrolling viewport now that
/// the content is a `ConstrainedBox` rather than a fixed `SizedBox` inside a
/// scroll view. That shape matters for this measurement: a `SizedBox` of
/// exactly 300 inside a `SingleChildScrollView` is handed unbounded height and
/// reports 300 in every configuration, including ones where the athlete can see
/// none of it, so a test written against it cannot observe what it claims to.
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

    testWidgets('is unchanged when the library is whole', (tester) async {
      await _pumpDialog(tester, truncated: false);

      expect(find.textContaining('start of your library'), findsNothing);
      expect(_listViewport(tester), 300.0);
    });

    // A small screen at an accessibility text scale is where the title and the
    // content genuinely cannot both have what they want. The list is allowed to
    // shrink there, since it scrolls, but it has to keep a usable window and
    // the dialog must not overflow: a windowed list reports its full height
    // while showing the athlete nothing, which is the failure a fixed SizedBox
    // hid twice.
    testWidgets(
      'leaves a usable list on a small screen at a large text scale',
      (tester) async {
        await _pumpDialog(
          tester,
          truncated: true,
          surface: const Size(320, 568),
          textScale: 2.0,
        );

        // Scoped to the vertical direction on purpose. This dialog's ListTile
        // subtitle overflows horizontally at this size and scale on dev too,
        // measured by checking out dev's copy of this screen and pumping it
        // here, so asserting on every exception would make this test fail for a
        // defect it is not about and cannot fix. The bottom overflow is the one
        // this PR introduced and the one it has to keep out.
        final overflow = tester.takeException();
        expect(
          overflow?.toString() ?? '',
          isNot(contains('on the bottom')),
          reason: 'the title must not push the dialog past its own height',
        );
        expect(
          _listViewport(tester),
          greaterThan(48.0),
          reason: 'the list must stay tall enough to show and scroll a row',
        );
      },
    );
  });
}

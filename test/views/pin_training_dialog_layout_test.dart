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

/// The dialog on a phone sized surface, with the library cut, which is the only
/// state in which the notice renders at all.
Future<void> _pumpDialog(WidgetTester tester, {required bool truncated}) async {
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        allTrainingsProvider.overrideWith((ref) async => _library(30)),
        trainingLibraryTruncatedProvider.overrideWith((ref) async => truncated),
      ],
      child: const MaterialApp(
        home: Scaffold(body: Center(child: PinTrainingDialog())),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('the pin training dialog', () {
    // The notice used to sit inside the dialog's fixed 300dp content box, above
    // an Expanded list. On a 360dp phone it wrapped to six lines and left the
    // list a 54dp window onto a two hundred entry library, which is less than
    // one row. The athlete past the ceiling is the only one who ever sees the
    // notice, so that took the screen away from exactly the person the feature
    // is for. It lives in the title area now, outside the budget.
    testWidgets('keeps the list its full height when the library was cut', (
      tester,
    ) async {
      await _pumpDialog(tester, truncated: true);

      expect(find.textContaining('start of your library'), findsOneWidget);
      final list = tester.getSize(find.byType(ListView).first);
      expect(
        list.height,
        300.0,
        reason: 'the notice must not take height from the training list',
      );
    });

    // And the same list, unchanged, when nothing was cut.
    testWidgets('is unchanged when the library is whole', (tester) async {
      await _pumpDialog(tester, truncated: false);

      expect(find.textContaining('start of your library'), findsNothing);
      expect(tester.getSize(find.byType(ListView).first).height, 300.0);
    });
  });
}

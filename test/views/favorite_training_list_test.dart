import 'package:crimpy/models/training.dart';
import 'package:crimpy/models/training_list_item.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:crimpy/views/screens/home_screen/favorite_training.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _Pinned extends PinnedTrainings {
  @override
  Future<List<TrainingListItem>> build() async => [
    for (var index = 0; index < 4; index++)
      TrainingListItem.regular(
        Training(id: 't-$index', title: 'Training $index', items: const []),
      ),
  ];
}

void main() {
  // The card leads the home screen, so it is sized to its list: a fixed box
  // scrolling its own list cut "Pin a training" off below the favourites.
  // See Krakoer/crimpy#165.
  testWidgets('keeps Pin a training in reach below every favourite', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pinnedTrainingsProvider.overrideWith(_Pinned.new),
          trainingLibraryTruncatedProvider.overrideWith((ref) async => false),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: FavoriteTrainingList()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final pin = find.text('Pin a training');
    expect(pin.hitTestable(), findsOneWidget);
    expect(
      tester.getRect(pin).top,
      greaterThan(tester.getRect(find.text('Training 3')).bottom),
    );
  });
}
